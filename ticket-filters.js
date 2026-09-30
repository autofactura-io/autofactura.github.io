autofactura.ticketFiltersTemplate = autofactura.ticketFiltersTemplate || fetch('autofactura/components/ticket-filters.xhtml').then(async response => {
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
    autofactura.ticketFiltersCleanup?.();
    const owner = anchor.closest('section');
    const id = name => `${prefix}-${name}`;
    const aside = document.createElement('aside');
    aside.id = id('sidebar');
    aside.className = `${prefix === 'fg' ? 'fg-sidebar' : 'rc-folio-filters'} ticket-filter-sidebar offcanvas offcanvas-end`;
    aside.setAttribute('tabindex', '-1');
    aside.setAttribute('aria-labelledby', id('filter-title'));
    aside.setAttribute('aria-label', prefix === 'fg' ? 'Filtros de tickets' : 'Filtros del concentrador');
    aside.setAttribute('aria-hidden', 'true');
    const backdrop = document.createElement('div');
    backdrop.className = 'ticket-filter-backdrop';
    backdrop.setAttribute('aria-hidden', 'true');
    const component = document.createElement('af-ticket-filters');
    component.setAttribute('prefix', prefix);
    component.setAttribute('apply-id', applyId);
    component.setAttribute('reset-id', resetId);
    component.setAttribute('help-text', helpText);
    aside.append(component);
    // Floating controls must not trigger the shell's page-replacement append event.
    document.body.appendChild(backdrop);
    document.body.appendChild(aside);
    try {
        await component.ready;
    } catch (error) {
        backdrop.remove();
        aside.remove();
        throw error;
    }
    if (!owner?.isConnected) {
        backdrop.remove();
        aside.remove();
        return null;
    }
    const calendarModal = component.calendarModal;
    document.body.appendChild(calendarModal);
    const toggle = document.createElement('button');
    toggle.id = id('filter-toggle');
    toggle.type = 'button';
    toggle.className = 'ticket-filter-toggle';
    toggle.setAttribute('aria-controls', aside.id);
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-label', 'Mostrar filtros');
    toggle.setAttribute('title', 'Filtros');
    toggle.innerHTML = '<svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 4h18l-7 8v6l-4 2v-8L3 4z"/></svg><span class="ticket-filter-toggle-count" hidden></span>';
    document.body.appendChild(toggle);
    const setOpen = open => {
        if (!aside.isConnected || !owner?.isConnected) return;
        aside.classList.toggle('is-open', open);
        backdrop.classList.toggle('is-open', open);
        aside.setAttribute('aria-hidden', String(!open));
        toggle.setAttribute('aria-expanded', String(open));
        toggle.setAttribute('aria-label', open ? 'Cerrar filtros' : 'Mostrar filtros');
        if (open) {
            aside.setAttribute('role', 'dialog');
            aside.setAttribute('aria-modal', 'true');
            aside.querySelector('.btn-close')?.focus();
        } else {
            aside.removeAttribute('role');
            aside.removeAttribute('aria-modal');
            toggle.focus();
        }
    };
    toggle.addEventListener('click', () => setOpen(!aside.classList.contains('is-open')));
    backdrop.addEventListener('click', () => setOpen(false));
    aside.querySelector('.btn-close')?.addEventListener('click', () => setOpen(false));
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
    aside.addEventListener('keydown', event => {
        if (event.key === 'Escape') setOpen(false);
    });
    const observer = new MutationObserver(() => {
        if (!owner?.isConnected) autofactura.ticketFiltersCleanup?.();
    });
    observer.observe(document.body, { childList: true, subtree: true });
    autofactura.ticketFiltersCleanup = () => {
        observer.disconnect();
        backdrop.remove();
        if (calendarModal.style.display !== 'none') closeCalendar();
        calendarModal.remove();
        toggle.remove();
        aside.remove();
        autofactura.ticketFiltersCleanup = null;
    };
    autofactura.restoreTicketFilters(aside, prefix);
    const remember = event => {
        if (event.target.matches('input, select')) autofactura.captureTicketFilters(aside, prefix);
    };
    aside.addEventListener('input', remember);
    aside.addEventListener('change', remember);
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
        branch: Boolean(value('sucursal')),
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
    const badge = root.querySelector(`#${prefix}-active-filter-count`);
    badge.hidden = count === 0;
    root.querySelector(`#${prefix}-active-filter-count-text`).textContent = `${count} ${count === 1 ? 'activo' : 'activos'}`;
    const toggleCount = document.querySelector(`#${prefix}-filter-toggle .ticket-filter-toggle-count`);
    if (toggleCount) {
        toggleCount.hidden = count === 0;
        toggleCount.textContent = count;
    }
};
