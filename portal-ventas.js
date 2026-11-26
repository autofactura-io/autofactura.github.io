(() => {
    const pageSize = 50;
    const metadata = 'http://panax.io/metadata';
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
        if (filters.desde && filters.hasta && filters.desde > filters.hasta) {
            root.setAttribute('error', 'La fecha inicial debe ser anterior o igual a la final.');
            return store.render();
        }
        pending.add(store);
        root.setAttribute('consultando', 'true');
        let queryingSales = false;
        try {
            if (!root.querySelector('catalogo')) {
                const catalog = await request('autofactura.portalTickets', { catalogo: 'filtros' }, 1);
                if (catalog?.localName !== 'catalogo') throw new Error('Catálogo no disponible.');
                root.appendChild(model.importNode(catalog, true));
                const companies = catalog.querySelectorAll('cliente');
                if (isVentas && !filters.tenant && [...companies].some(company => company.getAttribute('id') === 'historica')) {
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
            root.querySelector('model, ventas, ventas-historica')?.remove();
            root.appendChild(model.importNode(result, true));
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
    function applySalesFilters(event) {
        const form = event.type === 'submit' ? event.target
            : event.target.closest?.('#portal-operacion-filtros button[type="submit"]')?.form;
        if (!form?.matches('#portal-operacion-filtros')) return;
        event.preventDefault();

        const store = xo.stores.active;
        const root = store?.document?.documentElement;
        const draft = root?.matches('reporte[modulo="ventas"]') && root.querySelector('filtros');
        if (!store || !draft || pending.has(store)) return;

        const submitted = new FormData(form);
        for (const name of fields) {
            if (submitted.has(name)) draft.setAttribute(name, String(submitted.get(name)).trim());
        }
        void search(store, 1, readFilters(draft));
    }
    window.addEventListener('click', applySalesFilters, true);
    window.addEventListener('submit', applySalesFilters, true);
    xo.listener.on('portal:pagina', function ({ target }) {
        const root = target.closest('#portal-operacion')?.scope;
        const store = storeFor(root);
        const page = Number(target.dataset.portalPage);
        if (store && Number.isInteger(page) && page > 0) return search(store, page, readFilters(root));
    });
    xo.listener.on(fields.map(name => 'change::@' + name), function () {
        const draft = this.ownerElement;
        const store = draft?.localName === 'filtros' && storeFor(draft.parentNode);
        if (!store) return;
        this.inert = true;
        if (this.localName === 'tenant') draft.setAttribute('sucursal', '');
        else if (this.localName !== 'informe') return;
        const form = document.getElementById('portal-operacion-filtros');
        if (form?.scope === draft) {
            const outlet = form.closest('.portal-filter-outlet[xo-stylesheet]');
            if (outlet) void outlet.render();
            else void store.render();
        }
    });
    xo.listener.on('failure', function ({ request, response, statusCodes }) {
        if (response?.status === 404 && reportRequests.has(request?.target)) statusCodes.ignored.push(404);
    }, { priority: 1 });
})();
