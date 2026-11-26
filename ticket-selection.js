(function () {
    const namespace = 'http://panax.io/state';
    const rows = () => [...(xover.stores['#facturas'].document?.querySelectorAll('model > row, model > selected-tickets > row') || [])];
    const isSelected = row => ['true', '1'].includes(row.getAttributeNS(namespace, 'selected'));
    const find = id => rows().find(row => row.getAttribute('id') === String(id));
    // This is a view of XML state, not a separate collection of selected IDs.
    let refreshPending = false;
    xover.listener.on('change::@state:selected', function (event) {
        if (this.ownerDocument !== xover.stores['#facturas'].document) return;
        // Selection is handled by the views; do not rebuild the store's report.
        event.preventDefault();
        if (refreshPending) return;
        refreshPending = true;
        queueMicrotask(() => {
            refreshPending = false;
            autofactura.fg?.refreshSelection?.();
            autofactura.refreshConcentradorSelection?.();
        });
    });
    autofactura.ticketSelection = {
        get size() { return rows().filter(isSelected).length; },
        has(id) { const row = find(id); return !!row && isSelected(row); },
        add(id) {
            const row = find(id);
            if (row && !isSelected(row)) row.setAttributeNS(namespace, 'state:selected', 'true');
            return this;
        },
        delete(id) {
            const row = find(id);
            const selected = !!row && isSelected(row);
            row?.removeAttributeNS(namespace, 'selected');
            return selected;
        },
        setMany(ids, selected) {
            const requested = new Set([...ids].map(String));
            for (const row of rows()) {
                if (!requested.has(row.getAttribute('id'))) continue;
                if (selected) {
                    if (!isSelected(row)) row.setAttributeNS(namespace, 'state:selected', 'true');
                } else row.removeAttributeNS(namespace, 'selected');
            }
        },
        selectOnly(id) {
            for (const row of rows()) {
                if (row.getAttribute('id') === String(id)) {
                    if (!isSelected(row)) row.setAttributeNS(namespace, 'state:selected', 'true');
                } else if (isSelected(row)) row.removeAttributeNS(namespace, 'selected');
            }
        },
        clear() {
            for (const row of rows()) if (isSelected(row)) row.removeAttributeNS(namespace, 'selected');
        },
        *[Symbol.iterator]() {
            for (const row of rows()) if (isSelected(row)) yield row.getAttribute('id');
        }
    };
})();
