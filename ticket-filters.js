autofactura.ticketFiltersTemplate = autofactura.ticketFiltersTemplate || fetch('autofactura/components/ticket-filters.xhtml?v=20261125_1').then(async response => {
    if (!response.ok) throw new Error('No se pudo cargar el componente de filtros');
    const html = await response.text();
    const document = new DOMParser().parseFromString(html, 'text/html');
    const template = document.querySelector('template');
    if (!template) throw new Error('La plantilla de filtros no es válida');
    return template;
});

if (!customElements.get('af-ticket-filters')) {
    customElements.define('af-ticket-filters', class extends HTMLElement {
        async connectedCallback() {
            if (this.ready) return;
            this.ready = autofactura.ticketFiltersTemplate.then(template => {
                const fragment = template.content.cloneNode(true);
                const prefix = this.getAttribute('prefix');
                const applyId = this.getAttribute('apply-id');
                const resetId = this.getAttribute('reset-id');
                for (const element of fragment.querySelectorAll('*')) {
                    for (const attribute of ['id', 'for']) {
                        const value = element.getAttribute(attribute);
                        if (value) element.setAttribute(attribute, value.replaceAll('__PREFIX__', prefix).replaceAll('__APPLY_ID__', applyId).replaceAll('__RESET_ID__', resetId));
                    }
                }
                fragment.querySelector('[data-filter-help]').textContent = this.getAttribute('help-text') || '';
                this.calendarModal = fragment.querySelector('[data-calendar-modal]');
                this.calendarModal.remove();
                if (prefix === 'fg') fragment.querySelectorAll('.ticket-filter-field').forEach(field => field.classList.add('fg-filter-field'));
                this.append(fragment);
            });
            await this.ready;
        }
    });
}

autofactura.mountTicketFilters = async function mountTicketFilters(anchor, { prefix, applyId, resetId, helpText }) {
    if (!anchor) return;
    const mountToken = {};
    autofactura.ticketFiltersMountToken = mountToken;
    autofactura.ticketFiltersCleanup?.();
    const owner = anchor.closest('section');
    const declared = anchor.matches('autofactura-filters');
    const panel = declared ? anchor : document.createElement('autofactura-filters');
    if (!declared) {
        panel.setAttribute('prefix', prefix);
        anchor.before(panel);
    }
    const aside = await xo.waitFor({ selector: 'aside[part="panel"][id]', root: panel }, 5000);
    if (!aside || !owner?.isConnected || autofactura.ticketFiltersMountToken !== mountToken) {
        if (!declared) panel.remove();
        return null;
    }
    aside.classList.add(prefix === 'fg' ? 'fg-sidebar' : 'rc-folio-filters');
    const component = document.createElement('af-ticket-filters');
    component.setAttribute('prefix', prefix);
    component.setAttribute('apply-id', applyId);
    component.setAttribute('reset-id', resetId);
    component.setAttribute('help-text', helpText);
    aside.appendChild(component);
    try {
        await component.ready;
    } catch (error) {
        component.remove();
        if (!declared) panel.remove();
        throw error;
    }
    if (!owner.isConnected || autofactura.ticketFiltersMountToken !== mountToken) {
        component.remove();
        if (!declared) panel.remove();
        return null;
    }
    if (prefix !== 'fg') {
        aside.querySelector('[data-filter-key="client"]')?.remove();
        aside.querySelector('[data-filter-key="recipient"]')?.remove();
    }
    const calendarModal = component.calendarModal;
    document.body.appendChild(calendarModal);
    aside.querySelector(`#${prefix}-f-date-range`)?.addEventListener('click', async () => {
        if (typeof openCalendar !== 'function') return;
        const start = aside.querySelector(`#${prefix}-f-start`);
        const end = aside.querySelector(`#${prefix}-f-end`);
        const { from, to, cancelled } = await openCalendar({
            label: 'Búsqueda por fecha',
            defaultDate: [start.value, end.value].filter(Boolean),
            maxDate: 'today'
        });
        if (cancelled) return;
        start.value = from || '';
        end.value = to || '';
        autofactura.updateTicketDateRangeLabel(aside, prefix);
        start.dispatchEvent(new Event('change', { bubbles: true }));
    });
    const observer = new MutationObserver(() => {
        if (!panel.isConnected) cleanup();
    });
    observer.observe(document.body, { childList: true, subtree: true });
    const cleanup = () => {
        observer.disconnect();
        if (calendarModal.style.display !== 'none') closeCalendar();
        calendarModal.remove();
        component.remove();
        if (!declared) panel.remove();
        if (autofactura.ticketFiltersCleanup === cleanup) autofactura.ticketFiltersCleanup = null;
    };
    autofactura.ticketFiltersCleanup = cleanup;
    autofactura.restoreTicketFilters(aside, prefix);
    const remember = event => {
        if (event.target.matches('input, select')) autofactura.captureTicketFilters(aside, prefix);
    };
    if (prefix !== 'fg') {
        aside.addEventListener('input', remember);
        aside.addEventListener('change', remember);
    }
    autofactura.updateTicketDateRangeLabel(aside, prefix);
    return aside;
};

autofactura.updateTicketDateRangeLabel = function updateTicketDateRangeLabel(aside, prefix) {
    const start = aside.querySelector(`#${prefix}-f-start`)?.value;
    const end = aside.querySelector(`#${prefix}-f-end`)?.value;
    const label = aside.querySelector('[data-date-range-label]');
    if (label) label.textContent = start && end ? `${start} — ${end}` : start ? `Desde ${start}` : end ? `Hasta ${end}` : 'Selecciona el rango';
};

autofactura.ticketFilterNames = ['start', 'end', 'folio', 'sucursal', 'formapago', 'min', 'max', 'producto', 'pago-unico', 'impuestos', 'estado'];

autofactura.parseTicketFilterTerms = function parseTicketFilterTerms(value) {
    return value.split(',').map(term => term.trim().toLowerCase()).filter(Boolean);
};

autofactura.captureTicketFilters = function captureTicketFilters(aside, prefix) {
    autofactura.ticketFilterState = Object.fromEntries(autofactura.ticketFilterNames.map(name => [name, aside.querySelector(`#${prefix}-f-${name}`).value]));
    autofactura.ticketFilterState['incluir-productos'] = aside.querySelector(`#${prefix}-f-incluir-productos`).checked;
};

autofactura.restoreTicketFilters = function restoreTicketFilters(aside, prefix) {
    const state = autofactura.ticketFilterState;
    if (!state) {
        autofactura.updateTicketDateRangeLabel(aside, prefix);
        return;
    }
    for (const name of autofactura.ticketFilterNames) {
        const control = aside.querySelector(`#${prefix}-f-${name}`);
        if (control.tagName === 'SELECT' && state[name] && ![...control.options].some(option => option.value === state[name])) continue;
        control.value = state[name] ?? control.value;
    }
    aside.querySelector(`#${prefix}-f-incluir-productos`).checked = Boolean(state['incluir-productos']);
    autofactura.updateTicketDateRangeLabel(aside, prefix);
};

autofactura.updateTicketFilterIndicators = function updateTicketFilterIndicators(root, prefix) {
    autofactura.updateTicketDateRangeLabel(root, prefix);
    const value = name => root.querySelector(`#${prefix}-f-${name}`)?.value || '';
    const active = {
        date: Boolean(value('start') || value('end')),
        folio: Boolean(value('folio').trim()),
        client: Boolean(value('cliente')),
        branch: Boolean(value('sucursal')),
        recipient: Boolean(value('receptor')),
        payment: Boolean(value('formapago')),
        amount: (value('min') !== '' && Number(value('min')) !== 0) || (value('max') !== '' && Number(value('max')) !== 9999.99),
        product: Boolean(value('producto').trim()),
        'single-payment': Boolean(value('pago-unico')),
        taxes: Boolean(value('impuestos')),
        status: Boolean(value('estado'))
    };
    let count = 0;
    for (const [key, isActive] of Object.entries(active)) {
        root.querySelector(`[data-filter-key="${key}"]`)?.classList.toggle('is-active', isActive);
        if (isActive) count++;
    }
    for (const group of root.querySelectorAll('.ticket-filter-group')) {
        const groupCount = group.querySelectorAll('.ticket-filter-field.is-active').length;
        const indicator = group.querySelector(':scope > summary > .ticket-filter-group-count');
        indicator.hidden = !groupCount;
        indicator.textContent = groupCount ? groupCount + (groupCount === 1 ? ' activo' : ' activos') : '';
    }
    const badge = root.querySelector(`#${prefix}-active-filter-count`);
    badge.hidden = count === 0;
    root.querySelector(`#${prefix}-active-filter-count-text`).textContent = `${count} ${count === 1 ? 'activo' : 'activos'}`;
    const toggleCount = document.querySelector(`#${prefix}-filter-toggle .ticket-filter-toggle-count`);
    if (toggleCount) {
        toggleCount.hidden = count === 0;
        toggleCount.textContent = count;
    }
};
