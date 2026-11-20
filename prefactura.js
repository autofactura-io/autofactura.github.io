(function () {
    const cents = value => Math.round((Number(value) || 0) * 100);
    const money = value => (value / 100).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    const unitMoney = value => (value / 100).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 6 });
    const escape = value => String(value ?? '').replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
    const sum = (rows, key) => rows.reduce((total, row) => total + row[key], 0);
    function readTickets(store, selectedIds = [...autofactura.ticketSelection]) {
        const ids = new Set((selectedIds || []).map(String));
        if (!ids.size) throw new Error('Selecciona al menos un ticket en Factura Global.');
        const number = (node, names, fallback = 0) => {
            for (const name of names) {
                const value = node.getAttribute(name);
                if (value != null && value !== '') {
                    const parsed = Number(value.replaceAll(',', ''));
                    if (Number.isFinite(parsed)) return parsed;
                }
            }
            return fallback;
        };
        const rate = (node, names, fallback = 0) => {
            const value = number(node, names, fallback);
            return Math.abs(value) > 1 ? value / 100 : value;
        };
        const tickets = [...store.document.querySelectorAll('model > row')].filter(row => ids.has(row.getAttribute('id'))).map(row => {
            const subtotal = number(row, ['st']);
            const tasaIVA = rate(row, ['tasaIVA', 'iva_tasa', 'tasa'], .16);
            const tasaIEPS = rate(row, ['tasaIEPS', 'ieps_tasa']);
            const items = [...row.querySelectorAll('items > item, :scope > item')].map(item => ({
                codigo: item.getAttribute('codigo') || '', descripcion: item.getAttribute('descripcion') || '',
                cantidad: number(item, ['cantidad', 'quantity']), base: number(item, ['base', 'subtotal'], NaN),
                unidad: item.getAttribute('unidad') || '', claveUnidad: item.getAttribute('clave_unidad') || '',
                claveProducto: item.getAttribute('clave_producto_servicio') || item.getAttribute('clave_sat') || '',
                precioArticulo: number(item, ['precio_articulo']), precioExtras: number(item, ['precio_extras']), importe: number(item, ['importe']),
                tasaIVA: rate(item, ['tasa_iva'], tasaIVA), tasaIEPS: rate(item, ['tasa_ieps'], tasaIEPS),
                iva: number(item, ['iva']), ieps: number(item, ['ieps'])
            }));
            const iva = number(row, ['iva', 'iva_total'], items.reduce((total, item) => total + item.iva, 0) || subtotal * tasaIVA);
            const ieps = number(row, ['ieps', 'ieps_total'], items.reduce((total, item) => total + item.ieps, 0) || subtotal * tasaIEPS);
            return { id: row.getAttribute('id'), folio: row.getAttribute('tkt'), fecha: (row.getAttribute('dt') || '').slice(0, 10), subtotal, iva, ieps, total: number(row, ['total'], subtotal + iva + ieps), items };
        });
        if (tickets.length !== ids.size) throw new Error('Algunos tickets seleccionados ya no están disponibles en #facturas. Revisa la selección.');
        return tickets;
    }
    function build(context) {
        const tickets = structuredClone(context.selectedTickets || []);
        if (!tickets.length) throw new Error('Selecciona al menos un ticket en Factura Global.');
        const groups = new Map();
        const warnings = new Set();
        for (const ticket of tickets) {
            const items = ticket.items?.length ? ticket.items : [{ descripcion: 'Ticket ' + ticket.folio, importe: ticket.subtotal, iva: ticket.iva, ieps: ticket.ieps, cantidad: 1 }];
            const bases = items.map(item => {
                // Prefer an explicit base; tax amounts also identify the taxable base.
                if (item.base != null && item.base !== '' && Number.isFinite(Number(item.base))) return cents(item.base);
                const rate = Number(item.tasaIVA) || Number(item.tasaIEPS);
                const tax = Number(item.tasaIVA) ? Number(item.iva) : Number(item.ieps);
                return rate && tax ? cents(tax / rate) : cents(item.importe);
            });
            const expected = cents(ticket.subtotal);
            const difference = expected - bases.reduce((a, b) => a + b, 0);
            // Preserve the source ticket subtotal, including its cent rounding.
            if (Math.abs(difference) > items.length) warnings.add('Algunos importes de conceptos se distribuyeron para conciliar con el subtotal de sus tickets. Revisa los conceptos.');
            const weight = bases.reduce((a, b) => a + Math.abs(b), 0);
            let allocated = 0;
            items.forEach((item, index) => {
                const adjustment = index === items.length - 1 ? difference - allocated : Math.round(difference * (weight ? Math.abs(bases[index]) / weight : 1 / items.length));
                allocated += adjustment;
                const base = bases[index] + adjustment;
                const unitPrice = Number(item.precioArticulo) + Number(item.precioExtras || 0);
                const explicitQuantity = Number(item.cantidad);
                const rawEstimate = unitPrice > 0 ? Number(item.importe) / unitPrice : 1;
                // Ticket prices rounded to cents can produce artificial fractions near 1.
                const estimate = Number(rawEstimate.toFixed(3)) || Number(rawEstimate.toFixed(6));
                const quantity = explicitQuantity > 0 ? explicitQuantity : estimate > 0 ? estimate : 1;
                if (!(explicitQuantity > 0)) warnings.add('Los tickets no incluyen todas las cantidades. Se estimaron con el precio del artículo; revísalas antes de imprimir.');
                const key = JSON.stringify([item.codigo, item.descripcion, item.unidad || '', item.claveUnidad || '', item.claveProducto || '', Number(item.tasaIVA) || 0, Number(item.tasaIEPS) || 0]);
                if (!groups.has(key)) groups.set(key, { key, description: item.descripcion || item.codigo || 'Concepto', code: item.codigo || '', quantity: 0, unit: item.unidad || '', unitCode: item.claveUnidad || '', productCode: item.claveProducto || '', base: 0, iva: 0, ieps: 0 });
                const group = groups.get(key);
                group.quantity += quantity;
                group.base += base;
                group.iva += cents(item.iva);
                group.ieps += cents(item.ieps);
            });
        }
        const concepts = [...groups.values()];
        const totals = { subtotal: sum(tickets.map(t => ({ value: cents(t.subtotal) })), 'value'), iva: sum(tickets.map(t => ({ value: cents(t.iva) })), 'value'), ieps: sum(tickets.map(t => ({ value: cents(t.ieps) })), 'value'), total: sum(tickets.map(t => ({ value: cents(t.total) })), 'value') };
        const dates = tickets.map(t => t.fecha).filter(Boolean).sort();
        const folios = tickets.map(t => t.folio).filter(value => value != null);
        const data = {
            tickets, concepts, totals, warnings: [...warnings],
            fields: { emisor: 'REBECA MARIA DOLORES HANELL CAMPBELL ESPARZA', emisorRfc: 'HAER710624DY6', regimenEmisor: '612', lugar: '78200', cliente: 'VENTAS AL PUBLICO', rfc: context.receptor || 'XAXX010101000', regimenCliente: '616 - Sin obligaciones fiscales', domicilio: '', uso: context.cfdi?.uso || 'S01 - Sin efectos fiscales', metodo: context.cfdi?.metodo || 'PUE - Pago en una sola exhibición', forma: context.cfdi?.forma || '', moneda: 'MXN - Peso Mexicano', periodicidad: '', serie: '', folio: '', fecha: [new Date().getFullYear(), String(new Date().getMonth() + 1).padStart(2, '0'), String(new Date().getDate()).padStart(2, '0')].join('-'), observaciones: `PRE-FACTURA CORRESPONDIENTE AL PERIODO ${dates[0] || ''} AL ${dates.at(-1) || ''}. FOLIOS INCLUIDOS: ${folios.join(', ')}.` }
        };
        return data;
    }
    function documentHtml(data) {
        const f = data.fields;
        const rows = data.concepts.map(c => `<tr><td class="number">${escape(Number(c.quantity.toFixed(6)))}</td><td>${escape(c.unit || 'Por definir')}<small>${escape(c.unitCode)}</small></td><td>${escape(c.description)}<small>Clave Producto/servicio SAT: ${escape(c.productCode || 'Por definir')}</small></td><td class="number">IVA: ${money(c.iva)}<small>IEPS: ${money(c.ieps)}</small></td><td class="number">${unitMoney(c.quantity ? c.base / c.quantity : 0)}</td><td class="number">${money(c.base)}</td></tr>`).join('');
        return `<!doctype html><html lang="es-MX"><head><meta charset="utf-8"><title>Pre-factura ${escape(f.folio)}</title><style>
        @page{size:letter;margin:12mm}*{box-sizing:border-box}body{font:11px Arial,sans-serif;color:#111;margin:0;background:white}.sheet{max-width:190mm;margin:auto}.head{display:grid;grid-template-columns:26fr 46fr 28fr;gap:10px;min-height:145px}.logo{width:160px;max-width:100%}.issuer{text-align:center;padding-top:8px}.issuer strong{display:block;font-size:12px}.issuer .regime{margin-top:45px}.title{background:#619cd2;color:white;text-align:center;font-size:14px;padding:5px}.data{line-height:1.7}.client{display:grid;grid-template-columns:45fr 55fr;gap:12px;margin:12px 0 20px}.client h2{font-size:12px;font-style:italic;margin:0 0 6px}.address{white-space:pre-line}.notes{white-space:pre-wrap;margin-bottom:9px;font-size:10px;overflow-wrap:anywhere}table{border-collapse:collapse;width:100%;table-layout:fixed}thead{display:table-header-group}th{background:#619cd2;color:white;border:1px solid #163f71;padding:7px 4px;font-size:10px}td{border-left:1px solid #163f71;border-right:1px solid #163f71;padding:9px 6px;vertical-align:top;overflow-wrap:anywhere}tbody tr:last-child td{border-bottom:1px solid #163f71}tr{break-inside:avoid}small{display:block;font-size:9px;margin-top:5px}.number{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap;overflow-wrap:normal}.bottom{display:flex;gap:20px;justify-content:space-between;align-items:flex-start;margin-top:14px;break-inside:avoid}.notice{padding:10px;background:#f1f5f9;flex:1}.totals{width:220px;line-height:1.9}.totals div{display:flex;justify-content:space-between}.grand{font-size:14px;border-top:1px solid #163f71;font-weight:bold}.footer{margin-top:18px;text-align:center;color:#555;font-size:10px}@media screen{body{padding:20px}}
        </style></head><body><article class="sheet"><header class="head"><div><img class="logo" src="${escape(new URL('assets/prefactura-logo.jpg', location.href).href)}" alt="La otra España"></div><div class="issuer"><strong>${escape(f.emisor)}</strong><p>R.F.C. ${escape(f.emisorRfc)}</p><div class="regime">RÉGIMEN FISCAL:<br>${escape(f.regimenEmisor)}</div></div><div class="data"><div class="title">Pre-factura</div>SERIE: ${escape(f.serie)}<br>FOLIO: ${escape(f.folio || 'Sin asignar')}<br>FECHA: ${escape(f.fecha)}<br>LUGAR DE EXPEDICIÓN: ${escape(f.lugar)}<br>TIPO: I - Ingreso</div></header><div class="client"><div><h2>CLIENTE:</h2>RFC: ${escape(f.rfc)}<br><strong>${escape(f.cliente)}</strong><div class="address">${escape(f.domicilio)}</div>Moneda: ${escape(f.moneda)}<br>Exportación: 01 - No aplica<br>Periodicidad: ${escape(f.periodicidad || 'Por definir')}</div><div class="data">Régimen fiscal cliente: ${escape(f.regimenCliente)}<br>Método de pago: ${escape(f.metodo)}<br>Forma de pago: ${escape(f.forma || 'Por definir')}<br>Uso de CFDI: ${escape(f.uso)}</div></div><div class="notes">${escape(f.observaciones)}</div><table><colgroup><col style="width:8%"><col style="width:11%"><col style="width:43%"><col style="width:13%"><col style="width:12%"><col style="width:13%"></colgroup><thead><tr><th>CANTIDAD</th><th>UNIDAD</th><th>DESCRIPCIÓN</th><th>IMPUESTOS</th><th>VALOR UNITARIO</th><th>IMPORTE</th></tr></thead><tbody>${rows}</tbody></table><div class="bottom"><div class="notice"><strong>PRE-FACTURA - SIN VALIDEZ FISCAL</strong><br>Documento de revisión de ${data.tickets.length} tickets. No contiene timbre, folio fiscal ni sellos digitales.</div><div class="totals"><div><span>SUBTOTAL:</span><span>$ ${money(data.totals.subtotal)}</span></div><div><span>IVA:</span><span>$ ${money(data.totals.iva)}</span></div><div><span>IEPS:</span><span>$ ${money(data.totals.ieps)}</span></div><div class="grand"><span>TOTAL:</span><span>$ ${money(data.totals.total)}</span></div></div></div><footer class="footer">Pre-factura para revisión previa a la emisión.</footer></article></body></html>`;
    }
    const api = autofactura.prefactura = {
        build, readTickets, documentHtml,
        async open(context = {}) {
            try {
                const store = xover.stores['#facturas'];
                await store.ready;
                api.context = { receptor: context.receptor, cfdi: context.cfdi };
                api.draft = build({ ...api.context, selectedTickets: readTickets(store) });
                api.conceptEdits = new Map();
                location.hash = '#prefactura';
            }
            catch (error) { console.error('No se pudo generar la pre-factura:', error); window.alert(error.message); }
        },
        async mount(root) {
            if (!root) return;
            const store = xover.stores['#facturas'];
            let current;
            try {
                await store.ready;
                if (!root.isConnected) return;
                current = build({ ...api.context, selectedTickets: readTickets(store) });
            } catch (error) {
                if (!root.isConnected) return;
                api.draft = null;
                root.querySelector('[data-empty]').textContent = error.message;
                root.querySelector('[data-empty]').hidden = false;
                root.querySelector('[data-content]').hidden = true;
                return;
            }
            if (api.draft) current.fields = api.draft.fields;
            api.conceptEdits ||= new Map();
            for (const concept of current.concepts) Object.assign(concept, api.conceptEdits.get(concept.key));
            api.draft = current;
            const draft = api.draft;
            const empty = root.querySelector('[data-empty]');
            const content = root.querySelector('[data-content]');
            empty.hidden = !!draft; content.hidden = !draft;
            if (!draft) return;
            const labels = { emisor:'Emisor', emisorRfc:'RFC del emisor', regimenEmisor:'Régimen del emisor', lugar:'Lugar de expedición (CP)', cliente:'Cliente', rfc:'RFC del cliente', regimenCliente:'Régimen del cliente', domicilio:'Domicilio del cliente', uso:'Uso de CFDI', metodo:'Método de pago', forma:'Forma de pago', moneda:'Moneda', periodicidad:'Periodicidad', serie:'Serie', folio:'Folio de pre-factura', fecha:'Fecha', observaciones:'Periodo y folios' };
            root.querySelector('[data-fields]').innerHTML = Object.entries(labels).map(([key,label]) => `<label>${label}${['domicilio','observaciones'].includes(key) ? `<textarea data-field="${key}" rows="2">${escape(draft.fields[key])}</textarea>` : `<input data-field="${key}" type="${key==='fecha'?'date':'text'}" value="${escape(draft.fields[key])}">`}</label>`).join('');
            root.querySelector('[data-concepts]').innerHTML = draft.concepts.map((c,i) => `<tr><td>${escape(c.description)}</td><td><input aria-label="Cantidad de ${escape(c.description)}" data-concept="${i}" data-key="quantity" type="number" min="0.000001" step="any" value="${Number(c.quantity.toFixed(6))}"></td><td><input aria-label="Unidad de ${escape(c.description)}" data-concept="${i}" data-key="unit" value="${escape(c.unit)}" placeholder="PIEZA / KILO"></td><td><input aria-label="Clave unidad de ${escape(c.description)}" data-concept="${i}" data-key="unitCode" value="${escape(c.unitCode)}" placeholder="H87 / KGM"></td><td><input aria-label="Clave SAT de ${escape(c.description)}" data-concept="${i}" data-key="productCode" value="${escape(c.productCode)}" placeholder="Por definir"></td><td class="text-end">${money(c.base)}</td></tr>`).join('');
            const messages = [...draft.warnings];
            if (draft.concepts.some(c => !c.productCode || !c.unitCode)) messages.push('Completa las unidades y claves SAT que no estén disponibles en el origen.');
            if (draft.totals.subtotal + draft.totals.iva + draft.totals.ieps !== draft.totals.total) messages.push('El total del origen no coincide con subtotal e impuestos. Revisa descuentos o ajustes del ticket.');
            if (sum(draft.concepts,'iva') !== draft.totals.iva || sum(draft.concepts,'ieps') !== draft.totals.ieps) messages.push('Los impuestos del detalle difieren del encabezado. Los totales conservan los importes originales de los tickets.');
            root.querySelector('[data-warning]').textContent = messages.join(' ');
            root.querySelector('[data-summary]').textContent = `${draft.tickets.length} tickets · ${draft.concepts.length} conceptos · Total $${money(draft.totals.total)}`;
            const frame = root.querySelector('iframe');
            const refresh = () => { frame.srcdoc = documentHtml(draft); };
            root.addEventListener('input', event => {
                const input = event.target;
                if (input.dataset.field) draft.fields[input.dataset.field] = input.value;
                if (input.dataset.concept != null) {
                    const concept = draft.concepts[Number(input.dataset.concept)];
                    const value = input.dataset.key === 'quantity' ? Number(input.value) : input.value;
                    concept[input.dataset.key] = value;
                    api.conceptEdits.set(concept.key, { ...api.conceptEdits.get(concept.key), [input.dataset.key]: value });
                }
            });
            const validQuantities = () => !draft.concepts.some(c => !Number.isFinite(c.quantity) || c.quantity <= 0);
            root.querySelector('[data-preview]').onclick = () => {
                if (!validQuantities()) { window.alert('Todas las cantidades deben ser mayores que cero.'); return; }
                refresh();
            };
            let printPending = false;
            const printStatus = root.querySelector('[data-print-status]');
            frame.onload = async () => {
                frame.contentWindow.addEventListener('beforeprint', () => { printStatus.textContent = 'Vista de impresión abierta.'; });
                frame.contentWindow.addEventListener('afterprint', () => { printStatus.textContent = 'Vista de impresión cerrada.'; });
                if (!printPending) return;
                printPending = false;
                const doc = frame.contentDocument;
                await Promise.all([...doc.images].map(img => img.complete ? Promise.resolve() : new Promise(resolve => { img.onload = resolve; img.onerror = resolve; })));
                frame.contentWindow.focus(); frame.contentWindow.print();
            };
            root.querySelector('[data-print]').onclick = () => {
                if (!validQuantities()) { window.alert('Todas las cantidades deben ser mayores que cero.'); return; }
                printStatus.textContent = 'Preparando impresión…';
                printPending = true; refresh();
            };
            refresh();
        }
    };
})();
