// Compatibility loader for XOver versions that predate is="..." behaviors.
// The selection logic itself lives in the XHTML widgets.
(function () {
  const sources = new Map([
    ['excel-selection', 'widgets/excel-selection.xhtml'],
    ['selection-summary', 'widgets/selection-summary.xhtml']
  ]);
  const definitions = new Map();
  const instances = new WeakMap();

  async function definition(name) {
    if (!definitions.has(name)) {
      definitions.set(name, (async () => {
        const response = await fetch(sources.get(name));
        if (!response.ok) throw new Error(`No se pudo cargar ${name}: ${response.status}`);
        const doc = new DOMParser().parseFromString(await response.text(), 'text/html');
        const template = doc.querySelector('template[role="behavior"]');
        const script = template?.content.querySelector('script')?.textContent;
        if (!script) throw new Error(`El behavior ${name} no contiene un script`);
        for (const style of doc.querySelectorAll('style')) {
          const element = document.createElement('style');
          element.textContent = style.textContent;
          document.head.append(element);
        }
        for (const globalScript of [...doc.querySelectorAll('script')].filter(node => !template.contains(node))) {
          new Function(globalScript.textContent).call(window);
        }
        return script;
      })());
    }
    return definitions.get(name);
  }

  function extend(host, methods) {
    for (const [name, descriptor] of Object.entries(methods)) {
      Object.defineProperty(host, name, typeof descriptor === 'function'
        ? { value: descriptor, writable: true, configurable: true }
        : { ...descriptor, configurable: true });
    }
  }

  async function enhance(node, name) {
    let applied = instances.get(node);
    if (!applied) instances.set(node, applied = new Map());
    if (applied.has(name)) return applied.get(name);
    const task = (async () => {
      const script = await definition(name);
      if (!node.isConnected) return;
      new Function('constructor', script).call(node, {
        host: node,
        extend(methods) { extend(node, methods); }
      });
      node.init?.();
    })();
    applied.set(name, task);
    return task;
  }

  function ready(root) {
    if (globalThis.xover?.init?.behaviors) return xover.init.behaviors.call(root);
    const nodes = [root, ...(root.querySelectorAll?.('[is]') || [])];
    return Promise.all(nodes.filter(node => node.nodeType === 1 && node.hasAttribute('is'))
      .flatMap(node => node.getAttribute('is').split(/\s+/)
        .filter(name => sources.has(name))
        .map(name => enhance(node, name))));
  }

  function disconnect(root) {
    const nodes = [root, ...(root.querySelectorAll?.('[is]') || [])];
    for (const node of nodes) {
      if (!instances.has(node)) continue;
      node.disconnectedCallback?.();
      instances.delete(node);
    }
  }

  const observer = new MutationObserver(mutations => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) if (node.nodeType === 1) ready(node).catch(console.error);
      for (const node of mutation.removedNodes) if (node.nodeType === 1 && !node.isConnected) disconnect(node);
    }
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => ready(document));
  else ready(document);

  globalThis.widgetBehaviors = { ready };
})();
