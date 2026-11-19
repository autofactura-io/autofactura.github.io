(() => {
    if (typeof window.toggleSidebar === 'function') return;
    const url = new URL('widgets/shell/shell.js', document.baseURI).href;
    if ([...document.scripts].some(script => script.src === url)) return;
    const script = document.createElement('script');
    script.src = url;
    document.head.appendChild(script);
})();
