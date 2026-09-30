//xover.disablePolyfill.toString = true
var datediff = function (intervalType, first_date, last_date = new Date()) {
    // Parse the input dates
    if (!(first_date && last_date)) return undefined;
    const first = first_date instanceof Date ? first_date : first_date.parseDate();
    const last = last_date instanceof Date ? last_date : last_date.parseDate();
    intervalType = intervalType.replace(/s$/, '');

    // Calculate the difference in milliseconds
    const diffMs = last - first;

    // Convert milliseconds to the specified interval type
    let diffInterval;
    switch (intervalType) {
        case 'year':
            diffInterval = diffMs / (1000 * 60 * 60 * 24 * 365.25);
            break;
        case 'month':
            diffInterval = diffMs / (1000 * 60 * 60 * 24 * 30.44);
            break;
        case 'day':
            diffInterval = diffMs / (1000 * 60 * 60 * 24);
            break;
        case 'hour':
            diffInterval = diffMs / (1000 * 60 * 60);
            break;
        case 'minute':
            diffInterval = diffMs / (1000 * 60);
            break;
        case 'second':
            diffInterval = diffMs / 1000;
            break;
        default:
            throw new Error('Invalid interval type');
    }

    // Return the result rounded to 2 decimal places
    return Math.floor(Math.round(diffInterval * 100) / 100);
}

formatDate = function (date) {
    return new Date((date instanceof Date) && date || Date.parse(`${date}T00:00:00`.replace(/(\d{4})-?(\d{2})-?(\d{2})T/, '$1-$2-$3T')))
}

xo.listener.on(['append::main > [xo-source][xo-store], body > [xo-source][xo-store]'], function ({ target }) {
  const self = this;
  let mutually_inclusive_selector = `slot,script,dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar],[role=complementary]`
  for (const node of [...target.children].filter(node =>
    node !== this && node.nodeType === Node.ELEMENT_NODE
    && node.matches(`[xo-store]`)
    && !node.matches(mutually_inclusive_selector)
    && !self.matches(mutually_inclusive_selector)
  )) {
    node.remove()
  }
})

xo.listener.on(['append::[id]'], function ({ target }) {
  if (!(target && typeof (target.checkVisibility) === 'function' && target.checkVisibility())) return;
  target.parentNode.querySelectorAll(`[id="${this.id}"]`).filter(el => el !== this).forEach(el => el.remove())
})
/*
xo.listener.on(['append::html:*[.//@style[contains(.,"view-transition-name")]]'], function ({ target, element }) {
    debugger
})*/

xo.listener.on(`fetch::model[*[@xsi:type="dimension"]]`, function ({ document }) {
    let dimensions = {};
    for (let dimension of document.select(`model/*[@xsi:type="dimension"][row]`)) {
        dimensions[dimension.nodeName] = Object.fromEntries(dimension.select("row").map((row) => [row.getAttributeNode("id") || row.getAttributeNode("key") || row.getAttributeNode("desc"), row.getAttributeNode("desc") || row.getAttributeNode("key") || row.getAttributeNode("id")]));
    }

    let dims = Object.fromEntries(document.select(`model/*[not(@xsi:type="dimension")]/@dim:*`).map(attr => [attr.localName, attr.value]));
    let fks = { ...dims };
    for (let attr of document.select(`model/*[not(@xsi:type="dimension")]/row//@*`).filter(attr => attr.name in fks)) {
        let [dim, key] = fks[attr.name].split(/\//);
        let node = key && (dimensions[dim][attr.value] || attr).parentNode.getAttributeNode(key.replace(/^@/, '')) || (dimensions[dim] || {})[attr.value] || attr;
        attr.value = node.value;
    }
})

//xo.listener.on(['fetch', 'Response:failure'], async function ({ request }) {
//    let trackers = request.trackers;
//    for (let tracker of trackers) {
//        let progress = tracker.querySelector('i progress');
//        progress.value = 100;
//    }
//    trackers.clear();
//})

xo.listener.on(['beforeFetch::?FROM=^PanaxBI.#server:request'], async function ({ request }) {
    let trackers = request.trackers;
    for (let tracker of trackers) {
        tracker.remove()
    }
    trackers.clear();
    trackers.add(document.body.appendChild(document.createElement("px-loader")));
})

xo.listener.on('beforeRender?!store.stylesheets.length::model[not(//processing-instruction())]', function ({ document, store }) {
    let tag = store.tag;
    store.addStylesheet({ href: tag.substring(1).split(/\?/, 1).shift() + '.xslt', target: "@#shell main" });
})

xo.listener.on(['transform'], ({ result }) => {
    result.$$('//text()[.="Infinity" or .="-Infinity" or .="NaN" or .="NaN días" or .="0.0" or .="0.0%" or .="(0.0)" or .="0.00" or .="0" or .="(0)" or .="$0"]').remove();
    xo.state.hide_empty && result.$$('//*[contains(@class,"remove-row-if-empty")][not(.//text())]//ancestor-or-self::html:tr').remove()
})

xo.listener.on('progress', function ({ percent }) {
    if (percent >= 100) {
        this.remove()
    }
})

xo.listener.on(`remove::[role=alert]`, function () {
    let request = this.request;
    if (!request) return;
    if (request.progress < 100) {
        request.abort()
    }
})

function createToast({ header, body }) {
    const toast = document.createElement('div');
    toast.innerHTML = `
        <div class="toast show position-fixed bottom-0 end-0 m-3" style="z-index: 9999;">
            <div class="toast-header">
                <strong class="me-auto">${header || 'Aviso'}</strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
            </div>
            <div class="toast-body">${body}</div>
        </div>
    `;
    document.body.appendChild(toast);
    return toast;
}

xover.listener.on('NetworkError', function ({ url }) {
    createToast({
        header: "Error de conexión"
        , body: `No se pudo acceder al servidor ${url.host}`
    })
})

xo.listener.on(`versionChange`, function (onAccept) {
    const toast = createToast({
        header: "Actualización disponible"
        , body: `Hay una nueva versión disponible 
                <button class="btn btn-sm btn-primary ms-2">Actualizar</button>` })

    toast.querySelector('button.btn-primary').addEventListener('click', () => {
        onAccept();
    });

    toast.querySelector('.btn-close').addEventListener('click', () => toast.remove());
    event.stopImmediatePropagation()
})

xover.listener.on('unhandledrejection?reason*=Error loading script https://accounts.google.com/gsi/client', async (event) => {
    event.preventDefault();
    throw (`#google_error`);
})