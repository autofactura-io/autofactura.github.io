(() => {
    if (typeof window.onGoogleLogin === 'function') return;
    const url = new URL('widgets/login.js', document.baseURI).href;
    if ([...document.scripts].some(script => script.src === url)) return;
    const script = document.createElement('script');
    script.src = url;
    document.head.appendChild(script);
})();
