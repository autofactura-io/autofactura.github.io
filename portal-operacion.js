(() => {
    const pageSize = 50;
    const metadata = 'http://panax.io/metadata';
    const filterNamespace = 'http://autofactura.io/filters';
    const fields = ['tenant', 'sucursal', 'desde', 'hasta', 'estado', 'agrupacion', 'informe', 'borrados'];
    const routes = { ventas: '#ventas', facturas: '#consulta_facturas' };
    const pending = new WeakSet();
    const reportRequests = new WeakSet();

    function storeFor(root) {
        const route = root?.localName === 'reporte' && routes[root.getAttribute('modulo')];
        if (!route) return;
        const store = xo.stores[route];
        if (store?.document?.documentElement === root) return store;
    }

    function readFilters(node) {
        return Object.fromEntries(fields.filter(name => node.hasAttribute(name))
            .map(name => [name, node.getAttribute(name).trim()]));
    }

    async function request(from, filters, page) {
        const query = xo.xml.createDocument('<query/>').documentElement;
        for (const [key, value] of Object.entries(filters)) {
            if (value) query.setAttribute(key, value);
        }
        const params = new URLSearchParams({ FROM: from, '@xml': new XMLSerializer().serializeToString(query) });
        const headers = new Headers({ Accept: 'application/xml, text/xml' });
        if (page) {
            headers.set('X-Page-Size', pageSize);
            headers.set('X-Page-Index', page);
        }
        const context = xo.xml.createDocument('<model/>');
        reportRequests.add(context);
        return (await xo.server.request.call(context, params, headers, { cache: 'no-store' }))?.documentElement;
    }

    async function search(store, page, filters) {
        if (pending.has(store) || xo.stores.active !== store) return;
        const model = store.document;
        const root = model.documentElement;
        const draft = root.querySelector('filtros');
        const isVentas = root.getAttribute('modulo') === 'ventas';
        const historicalSalesOnly = xo.session.autofactura_access === 'historica_ventas';
        if (historicalSalesOnly) {
            if (!isVentas) return;
            const informe = filters.informe === 'conciliacion' ? 'conciliacion' : 'diario';
            filters = { ...filters, tenant: 'historica', informe };
        }
        if (filters.desde && filters.hasta && filters.desde > filters.hasta) {
            root.setAttribute('error', 'La fecha inicial debe ser anterior o igual a la final.');
            return store.render();
        }
        pending.add(store);
        root.setAttribute('consultando', 'true');
        let queryingSales = false;
        try {
            if (historicalSalesOnly) {
                for (const name of ['tenant', 'informe']) {
                    if (draft.getAttribute(name) !== filters[name]) draft.setAttribute(name, filters[name]);
                }
            }
            if (!root.querySelector('catalogo')) {
                const endpoint = historicalSalesOnly ? 'autofactura.portalVentasHistoricaCatalogo' : 'autofactura.portalTickets';
                const catalog = await request(endpoint, { catalogo: 'filtros' }, historicalSalesOnly ? undefined : 1);
                if (catalog?.localName !== 'catalogo') throw new Error('Catálogo no disponible.');
                root.appendChild(model.importNode(catalog, true));
                if (isVentas && !filters.tenant && catalog.querySelector('cliente[id="historica"]')) {
                    filters = { ...filters, tenant: 'historica' };
                    if (!draft.getAttribute('tenant')) draft.setAttribute('tenant', 'historica');
                }
            }
            const historicalSales = isVentas && filters.tenant === 'historica' && filters.informe !== 'resumen';
            const query = { ...filters };
            if (!filters.desde && !filters.hasta) query.periodo = 'actual';
            if (!isVentas) query.order_by = '[@tkt]';
            queryingSales = isVentas;
            if (!historicalSales) {
                delete query.informe;
                delete query.borrados;
            }
            const endpoint = historicalSales ? 'autofactura.portalVentasHistorica'
                : isVentas ? 'autofactura.portalVentas' : 'autofactura.portalTickets';
            const result = await request(endpoint, query, !isVentas || historicalSales ? page : undefined);
            const resultTag = historicalSales ? 'ventas-historica' : isVentas ? 'ventas' : 'model';
            if (result?.localName !== resultTag || (!isVentas && Number(result.getAttributeNS(metadata, 'pageIndex')) !== page)) {
                throw new Error('La respuesta de la consulta no coincide.');
            }
            root.querySelector('detalle-dia')?.remove();
            root.querySelector('model, ventas, ventas-historica')?.remove();
            root.appendChild(model.importNode(result, true));
            const open = result.getAttributeNS(filterNamespace, 'open');
            if (open === null) root.removeAttributeNS(filterNamespace, 'open');
            else root.setAttributeNS(filterNamespace, 'autofactura-filters:open', open);
            for (const name of fields) root.setAttribute(name, filters[name] ?? '');
            for (const date of ['desde', 'hasta']) {
                const effective = result.getAttribute(date);
                if (!effective) continue;
                root.setAttribute(date, effective);
                if (draft.getAttribute(date) === filters[date]) draft.setAttribute(date, effective);
            }
            root.removeAttribute('error');
        } catch (error) {
            const salesUnavailable = queryingSales && Number(error?.status) === 404;
            const message = isVentas ? 'No se pudieron consultar las ventas. Vuelve a intentarlo.' : 'No se pudieron consultar los tickets. Vuelve a intentarlo.';
            root.setAttribute('error', salesUnavailable ? 'La consulta de ventas todavía no está disponible en el servidor.' : message);
            console.error('Autofactura:', error?.message || error?.status);
        } finally {
            pending.delete(store);
            root.removeAttribute('consultando');
            if (xo.stores.active === store && store.document === model) await store.render();
        }
    }

    function loadReport() {
        const store = xo.stores.active;
        const root = store?.document?.documentElement;
        const draft = root?.localName === 'reporte' && root.querySelector('filtros');
        const user = String(xo.session.user_login ?? '').trim().toLowerCase();
        if (!draft || !user || user === 'mayorga' || root.hasAttribute('error') || root.querySelector('model, ventas, ventas-historica')) return;
        void search(store, 1, readFilters(draft));
    }

    // A cached report template may still request initialization explicitly.
    autofactura.operacion = { mount: loadReport };
    xo.listener.on('render', loadReport);
    xo.listener.on('portal:abrirFiltros', function ({ target }) {
        const root = target.closest('#portal-operacion')?.scope;
        if (storeFor(root) !== xo.stores.active) return;
        document.getElementById(`portal-${root.getAttribute('modulo')}-filters`)?.requestFiltersOpen(true);
    });
    xo.listener.on('portal:consultar', function ({ target }) {
        const store = xo.stores.active;
        const root = store?.document?.documentElement;
        const draft = root?.querySelector('filtros');
        if (!draft || storeFor(root) !== store || !target?.matches('#portal-operacion-filtros') || pending.has(store)) return;
        const submitted = new FormData(target);
        for (const name of fields) {
            if (submitted.has(name)) draft.setAttribute(name, String(submitted.get(name)).trim());
        }
        return search(store, 1, readFilters(draft));
    });
    xo.listener.on('portal:pagina', function ({ target }) {
        const root = target.closest('#portal-operacion')?.scope;
        const store = storeFor(root);
        const page = Number(target.dataset.portalPage);
        if (store && Number.isInteger(page) && page > 0) return search(store, page, readFilters(root));
    });
    function historicalStore(root) {
        const store = storeFor(root);
        if (store && store === xo.stores.active && root.querySelector('ventas-historica')) return store;
    }

    xo.listener.on('portal:informe', function ({ target }) {
        const store = xo.stores.active;
        const root = store?.document?.documentElement;
        if (!target?.matches('#shell button[data-portal-report]') || storeFor(root) !== store ||
            pending.has(store) || root?.getAttribute('modulo') !== 'ventas' ||
            !root.querySelector('catalogo > cliente[id="historica"]')) return;
        const informe = target.dataset.portalReport;
        if (![...root.querySelectorAll('formatos > formato')].some(format => format.getAttribute('id') === informe)) return;

        const draft = root.querySelector('filtros');
        const filters = readFilters(root);
        const sucursal = filters.tenant === 'historica' ? filters.sucursal : '';
        const next = { ...readFilters(draft), desde: '', hasta: '', ...filters, tenant: 'historica', sucursal, informe };
        for (const name of fields) {
            if (name in next && draft.getAttribute(name) !== next[name]) draft.setAttribute(name, next[name]);
        }
        return search(store, 1, next);
    });

    xo.listener.on('portal:mes', function ({ target }) {
        const root = target.closest('.historica-meses')?.scope;
        const store = historicalStore(root);
        if (!store || pending.has(store)) return;
        const month = [...root.querySelectorAll('periodos > mes')]
            .find(item => item.getAttribute('id') === target.dataset.portalMonth);
        if (!month) return;
        const desde = month.getAttribute('desde');
        const hasta = month.getAttribute('hasta');
        const draft = root.querySelector('filtros');
        draft.setAttribute('desde', desde);
        draft.setAttribute('hasta', hasta);
        return search(store, 1, { ...readFilters(root), desde, hasta });
    });

    xo.listener.on('portal:dia', async function ({ target }) {
        const root = target.closest('#portal-operacion')?.scope;
        const store = historicalStore(root);
        const date = target.dataset.portalDay;
        const page = Number(target.dataset.portalPage || 1);
        if (!store || pending.has(store) || !Number.isInteger(page) || page < 1) return;
        const day = [...root.querySelectorAll('ventas-historica > dia')].find(item => item.getAttribute('fecha') === date);
        if (!day || day.getAttribute('tieneDetalle') === '0') return;
        const previous = root.querySelector('detalle-dia');
        const sameDay = previous?.getAttribute('fecha') === date;
        if (sameDay && !target.dataset.portalPage) {
            previous.remove();
            return store.render();
        }
        if (sameDay && previous.hasAttribute('consultando')) return;
        previous?.remove();

        const model = store.document;
        const detail = model.createElement('detalle-dia');
        detail.setAttribute('fecha', date);
        detail.setAttribute('pagina', page);
        detail.setAttribute('consultando', 'true');
        root.appendChild(detail);
        const current = () => store.document === model && detail.parentNode === root;
        await store.render();
        if (!current()) return;
        try {
            const result = await request('autofactura.portalVentasHistorica', {
                ...readFilters(root),
                desde: date,
                hasta: date
            }, page);
            if (result?.localName !== 'ventas-historica' ||
                result.getAttribute('desde') !== date || result.getAttribute('hasta') !== date) {
                throw new Error('La respuesta del detalle no coincide con el día solicitado.');
            }
            if (current()) detail.appendChild(model.importNode(result, true));
        } catch (error) {
            if (current()) detail.setAttribute('error', 'No se pudo consultar el detalle de este día.');
            console.error('Autofactura:', error?.message || error?.status);
        } finally {
            if (current()) {
                detail.removeAttribute('consultando');
                if (xo.stores.active === store) await store.render();
            }
        }
    });

    xo.listener.on(fields.map(name => 'change::@' + name), function () {
        const draft = this.ownerElement;
        const store = draft?.localName === 'filtros' && storeFor(draft.parentNode);
        if (!store) return;
        this.inert = true;
        if (this.localName === 'tenant') draft.setAttribute('sucursal', '');
        else if (this.localName !== 'informe') return;
        const form = document.getElementById('portal-operacion-filtros');
        if (xo.stores.active === store && form?.scope === draft) void store.render();
    });
    xo.listener.on('failure', function ({ request, response, statusCodes }) {
        if (response?.status === 404 && reportRequests.has(request?.target)) statusCodes.ignored.push(404);
    }, { priority: 1 });
})();
