let rutaPendienteAutofactura;
let montajeAutofactura;

function sesionAutofacturaAutorizada() {
    return xo.session.status === 'authorized' && Boolean(xo.session.authorization);
}

function rutaInicialAutofactura() {
    if (String(xo.session.user_login || '').trim().toLowerCase() === 'mayorga') {
        return '#resumen_descarga_cfdi';
    }
    return '#factura_global';
}

function esRutaAutofactura(hash) {
    return Boolean(hash && hash !== '#' && hash !== '#login');
}

function fijarRutaAutofactura(ruta, entradaPredeterminada = false) {
    const url = entradaPredeterminada ? location.pathname + location.search : ruta;
    const seed = entradaPredeterminada ? '#' : ruta;
    history.replaceState({ ...history.state, seed, active: ruta }, '', url);
}

function alternarSuperficieAutofactura(autorizada) {
    document.documentElement.setAttribute('data-autofactura-authorized', String(autorizada));
    const body = document.body;
    if (!body) return;
    for (const [id, hidden] of [['autofactura-app', !autorizada], ['autofactura-access', autorizada]]) {
        let destino = document.getElementById(id);
        if (!destino) {
            destino = document.createElement('div');
            destino.id = id;
            body.appendChild(destino);
        }
        destino.hidden = hidden;
        if (id === 'autofactura-access' && !destino.querySelector('#autofactura-login-view')) {
            const view = document.createElement('section');
            view.id = 'autofactura-login-view';
            destino.appendChild(view);
        }
    }
}

function prepararRutaDeAccesoAutofactura() {
    if (esRutaAutofactura(location.hash)) rutaPendienteAutofactura = location.hash;
    fijarRutaAutofactura('#', true);
}

function prepararAccesoAutofactura() {
    prepararRutaDeAccesoAutofactura();
    alternarSuperficieAutofactura(false);
    document.getElementById('shell')?.remove();
}

function elegirRutaAutofactura() {
    const inicio = rutaInicialAutofactura();
    const puedeRestaurar = ruta => {
        const tag = ruta?.split('?')[0];
        return tag !== '#resumen_descarga_cfdi'
            && xo.manifest.settings[tag]?.target === '@#shell main';
    };
    return inicio === '#resumen_descarga_cfdi' ? inicio
        : [location.hash, rutaPendienteAutofactura].find(puedeRestaurar) || inicio;
}

function iniciarAutofactura() {
    montajeAutofactura ??= montarAutofactura().finally(() => { montajeAutofactura = undefined; });
    return montajeAutofactura;
}

async function montarAutofactura() {
    if (!document.body && document.readyState === 'loading') {
        await new Promise(resolve => document.addEventListener('DOMContentLoaded', resolve, { once: true }));
    }
    if (!sesionAutofacturaAutorizada()) return;

    const entradaPredeterminada = !esRutaAutofactura(location.hash) && !rutaPendienteAutofactura;
    const ruta = elegirRutaAutofactura();
    rutaPendienteAutofactura = undefined;
    const montarShell = document.getElementById('autofactura-app')?.hidden || !document.querySelector('#shell main');
    fijarRutaAutofactura(ruta, entradaPredeterminada);
    alternarSuperficieAutofactura(true);
    if (montarShell) await xo.stores['#shell'].render();
    if (!sesionAutofacturaAutorizada()) return mostrarAccesoAutofactura();
    if (location.hash === (entradaPredeterminada ? '' : ruta)) return xo.stores[ruta].render();
}


async function iniciarSesionAutofactura(form) {
    const message = form.querySelector('[role="alert"]');
    const button = form.querySelector('button[type="submit"]');
    message.textContent = '';
    xo.session.login_error = '';
    button.disabled = true;
    try {
        const username = form.elements.UserName.value.trim().toLowerCase();
        const password = xo.cryptography.encodeMD5(form.elements.Password.value).toUpperCase();
        await xo.session.login(username, password);
    } catch (error) {
        const status = Number(error?.status);
        const text = [401, 409].includes(status)
            ? 'Usuario o contraseña incorrectos.'
            : 'No fue posible iniciar sesión. Vuelve a intentarlo.';
        xo.session.login_error = text;
        message.textContent = text;
    } finally {
        if (button.isConnected) button.disabled = false;
    }
}

async function mostrarAccesoAutofactura() {
    prepararAccesoAutofactura();
    await xo.stores['#login'].render();
}

xo.listener.on('beforeRender::#shell', function ({ event }) {
    if (!sesionAutofacturaAutorizada()) event.preventDefault();
});
xo.listener.on('beforeRender::#login', function () {
    prepararAccesoAutofactura();
});
xo.listener.on('xover-initializing', function () {
    if (!sesionAutofacturaAutorizada()) {
        prepararRutaDeAccesoAutofactura();
        return;
    }
    iniciarAutofactura().catch(error => console.error('Autofactura:', error?.status || error?.name));
});
xo.listener.on('xover-initialized', function () {
    const mount = sesionAutofacturaAutorizada() ? iniciarAutofactura : mostrarAccesoAutofactura;
    return mount().catch(error => console.error('Autofactura:', error?.status || error?.name));
});
xo.listener.on('login', function () {
    // XOver actualiza la autorización de Basic al terminar el evento de login.
    setTimeout(() => iniciarAutofactura().catch(error => console.error('Autofactura:', error?.status || error?.name)), 0);
});
xo.listener.on('logout', mostrarAccesoAutofactura);


function mostrarDetalleSolicitud(solicitudId) {
    const detail = document.getElementById(solicitudId);
    if (!detail) return false;
    for (const other of detail.parentNode.querySelectorAll('details')) other.open = false;
    detail.open = true;
    detail.querySelector('summary')?.focus({ preventScroll: true });
    detail.scrollIntoView({ block: 'nearest' });
    return false;
}

xo.listener.on('beforeFetch', function ({ request }) {
    const url = new URL(request.url.href, location.href);
    const pathname = url.pathname;
    if (/\.css$/i.test(pathname)) request.headers.set('Accept', 'text/css');
    if (url.origin !== location.origin) return;
    if (/\.(xml|xhtml|resx)$/i.test(pathname)) request.headers.set('Accept', '*/*');
    if (/\.xslt$/i.test(pathname)) request.headers.set('Accept', 'application/xml, text/xml');
});


    (() => {
    if (window.autofacturaVisorCFDIInicializado) return;
    window.autofacturaVisorCFDIInicializado = true;
    const reportTag = '#resumen_descarga_cfdi';
    const reportIsActive = () => (location.hash || history.state?.active) === reportTag;
    const filterNames = ['empresa', 'fecha_consultada', 'uuid', 'sentido', 'estatus'];
    const stateNamespace = 'http://panax.io/state';
    let appliedFilters = {};
    let requestedFilters;

    function readReportFilters() {
        const model = xo.stores[reportTag].document.documentElement;
        const activeDateFilter = String(xo.state.filterBy_2) === 'uuid' ? 'uuid' : 'fecha_consultada';
        const filters = {};
        for (const name of filterNames) {
            if ((name === 'fecha_consultada' || name === 'uuid') && name !== activeDateFilter) continue;
            const field = [...model?.children || []].find(node => node.localName === name);
            const value = field?.getAttributeNS(stateNamespace, 'selected')?.trim();
            if (value) filters[name] = value;
        }
        return filters;
    }

    function updateRefreshButton(restart = false) {
        const button = document.getElementById('cfdi-refresh');
        if (!reportIsActive() || !button?.update) return;
        const draft = readReportFilters();
        const dirty = filterNames.some(name => draft[name] !== appliedFilters[name]);
        button.update(dirty, restart);
    }

    xo.listener.on('change::@state:selected', function ({ document }) {
        if (!reportIsActive() || document !== xo.stores[reportTag].document ||
            !filterNames.includes(this.ownerElement?.localName)) return;
        this.inert = true;
        updateRefreshButton(true);
    });
    window.addEventListener('change', function (event) {
        const field = event.target;
        if (!reportIsActive() || !field.matches?.('px-daterange[name=fecha_consultada][xo-slot="state:selected"]')) return;
        const model = xo.stores[reportTag].document.documentElement;
        const dateFilter = [...model?.children || []].find(node => node.localName === 'fecha_consultada');
        if (!dateFilter) return;
        const value = field.value || '';
        if (dateFilter.getAttributeNS(stateNamespace, 'selected') !== value) {
            dateFilter.setAttributeNS(stateNamespace, 'state:selected', value);
        }
        updateRefreshButton(true);
    }, true);
    xo.listener.on('input::input[name=uuid][xo-slot]', function () {
        if (!reportIsActive()) return;
        const selection = this.scope;
        if (selection?.ownerDocument === xo.stores[reportTag].document) selection.set(this.value);
    });
    xo.listener.on('changeFilter', function () {
        queueMicrotask(() => updateRefreshButton(true));
    });

    async function refreshReport(button) {
        if (requestedFilters || !reportIsActive()) return;
        requestedFilters = readReportFilters();
        const params = new URLSearchParams({ FROM: '[DescargaMasiva].[reporteDescargaCFDI]' });
        for (const name of filterNames) {
            if (requestedFilters[name]) params.set('@' + name, requestedFilters[name]);
        }
        button.setAttribute('aria-disabled', 'true');
        button.setAttribute('aria-busy', 'true');
        try {
            const context = xo.xml.createDocument('<reporte/>');
            const request = xo.server.request;
            const result = await request.call(context, params, new Headers({ Accept: 'application/xml, text/xml' }), { cache: 'no-store' });
            const report = result?.getElementsByTagName?.('DescargaMasiva')[0];
            if (!report) throw new Error('Respuesta de reporte inesperada.');
            const store = xo.stores[reportTag];
            store.document = result;
            await store.render();
            appliedFilters = requestedFilters;
        } catch {
            xo.dom.alert('No se pudo actualizar el reporte. Vuelve a intentarlo.');
        } finally {
            requestedFilters = undefined;
            button.removeAttribute('aria-disabled');
            button.removeAttribute('aria-busy');
            updateRefreshButton();
        }
    }

    xo.listener.on('cfdiFilterRefresh', function ({ target }) {
        if (target?.matches?.('px-refresh#cfdi-refresh')) return refreshReport(target);
    });

    window.addEventListener('click', function (event) {
        const control = event.target.closest?.('[data-cfdi-uuid]');
        if (!control) return;
        event.preventDefault();
        event.stopPropagation();
        abrirVisorCFDI(control);
    }, true);

    async function abrirVisorCFDI(link) {
        const uuid = link.dataset.cfdiUuid.trim();
        if (!/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(uuid) ||
            link.getAttribute('aria-busy') === 'true') return;
        link.setAttribute('aria-busy', 'true');
        try {
            const request = xo.server.request;
            const context = xo.xml.createDocument('<visor/>');
            const result = await request.call(context, new URLSearchParams({
                FROM: '[DescargaMasiva].[visualizarCFDI]',
                '@uuid': uuid
            }), new Headers({ Accept: 'application/xml, text/xml' }), { cache: 'no-store' });
            const comprobante = result?.getElementsByTagNameNS?.('http://www.sat.gob.mx/cfd/4', 'Comprobante')[0];
            if (!comprobante) {
                xo.dom.alert('El XML del comprobante no está disponible.');
                return;
            }
            const xml = xo.xml.createDocument(new XMLSerializer().serializeToString(comprobante));
            await mostrarVisorCFDI(xml);
        } catch (error) {
            console.warn('Visor CFDI: error', Number(error?.status) || error?.name);
            xo.dom.alert([404, 204, 409].includes(Number(error?.status))
                ? 'El XML del comprobante no está disponible.'
                : 'No se pudo abrir el comprobante. Vuelve a intentarlo.');
        } finally {
            link.removeAttribute('aria-busy');
        }
    }

    let cfdiStylesheet;

    async function mostrarVisorCFDI(xml) {
        if (!cfdiStylesheet) {
            const stylesheetUrl = location.origin + '/cfdi.xslt';
            cfdiStylesheet = xo.sources[stylesheetUrl].ready.catch(error => {
                cfdiStylesheet = undefined;
                throw error;
            });
        }
        const stylesheet = await cfdiStylesheet;
        const rendered = await xml.transform(stylesheet);
        const transformed = rendered?.querySelector?.('.descarga-cfdi-visor');
        if (!transformed) throw new Error('La transformación no generó el visor CFDI.');
        const viewer = document.importNode(transformed, true);
        document.getElementById('visor-cfdi-host')?.remove();
        const host = document.createElement('div');
        host.id = 'visor-cfdi-host';
        host.setAttribute('role', 'dialog');
        const shadow = host.attachShadow({ mode: 'open' });
        const widgetStyle = viewer.querySelector('.cfdi-reference link[rel=stylesheet]');
        if (widgetStyle) {
            const stylesheetLink = document.createElement('link');
            stylesheetLink.rel = 'stylesheet';
            stylesheetLink.href = new URL(widgetStyle.getAttribute('href'), location.origin + '/').href;
            widgetStyle.remove();
            shadow.appendChild(stylesheetLink);
        }
        shadow.appendChild(viewer);
        document.documentElement.appendChild(host);
        viewer.addEventListener('close', () => host.remove(), { once: true });
        viewer.showModal();
        const qr = viewer.querySelector('[data-cfdi-qr]');
        if (qr) dibujarQrCFDI(qr);
    }

    async function dibujarQrCFDI(container) {
        try {
            if (!window.QRCode) {
                window.pxQRCodeReady ||= new Promise((resolve, reject) => {
                    const script = document.createElement('script');
                    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js';
                    script.onload = resolve;
                    script.onerror = () => {
                        script.remove();
                        reject(new Error('No se pudo cargar la biblioteca QR.'));
                    };
                    document.head.appendChild(script);
                }).catch(error => {
                    window.pxQRCodeReady = null;
                    throw error;
                });
                await window.pxQRCodeReady;
            }
            if (!container.isConnected) return;
            new window.QRCode(container, {
                text: container.dataset.cfdiQr,
                width: 160,
                height: 160,
                correctLevel: window.QRCode.CorrectLevel.H
            });
        } catch {
            container.textContent = 'Código QR no disponible. Usa el enlace de verificación.';
        }
    }
})();
