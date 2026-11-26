<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">
<xsl:template match="/factura-global">
<xsl:variable name="cliente" select="@modo='cliente'"/>
<section id="page-content">
<section id="factura-global" class="fg" data-modo="{@modo}">

	<style>
		#shell &gt; footer:has(.fg-summary-row) {
			display: flex !important;
			align-items: center !important;
		}

		#factura-global[data-modo="cliente"] #fg-chk-all { display: none; }

		.fg-summary-row div {
			align-self: center;
		}
		/* ==== Scope: solo aplica dentro de #factura-global ==== */
		#factura-global {
			--fg-toolbar-h: 3.25rem;
		}

		#top-loader {
			position: sticky;
			top: 0;
			left: 0;
			height: 3px;
			width: 0%;
			background: linear-gradient(90deg,#0d6efd,#20c997,#ffc107,#0d6efd);
			background-size: 300% 100%;
			z-index: 5;
			transition: width .25s ease;
			animation: fg-hue 3s linear infinite;
		}

		@keyframes fg-hue {
			0% {
				background-position: 0 0
			}

			100% {
				background-position: 300% 0
			}
		}

		#factura-global .toolbar {
			position: sticky;
			top: 0;
			z-index: 4;
			background: #fff;
			border-bottom: 1px solid #e9ecef;
		}

		#factura-global .table thead th.sticky {
			position: sticky;
			top: var(--fg-toolbar-h);
			background: #fff;
			z-index: 3;
			box-shadow: inset 0 -1px 0 #cfd6df;
		}

		/* Bootstrap aplica overflow-x a .table-responsive; eso impide que el
			 encabezado se adhiera al área que realmente hace scroll. */
		#factura-global .table-responsive {
			overflow: visible;
			position: relative;
		}

		#factura-global #fg-tbl {
			width: 100%;
			min-width: 100%;
			border-collapse: separate;
			border-spacing: 0;
		}

			#factura-global #fg-tbl thead th.sticky {
				position: sticky;
				top: var(--fg-toolbar-h);
				z-index: 4;
				background: #fff;
				box-shadow: inset 0 -2px 0 #9aa6b2;
			}

		#factura-global #fg-data-binding {
			display: flex;
			flex-direction: column;
		}

			#factura-global #fg-data-binding &gt; .d-flex {
				order: 1;
			}

			#factura-global #fg-data-binding &gt; .table-responsive {
				order: 2;
			}

			#factura-global #fg-data-binding &gt; #fg-footer {
				order: 3;
			}

		#factura-global .fg-layout {
			display: block;
		}

		#factura-global .fg-content {
			width: 100%;
			margin-block: 1rem;
		}

		#factura-global .fg-main {
			min-width: 0;
			width: 100%;
		}

		#factura-global .fg-header-actions {
			display: flex;
			flex-wrap: wrap;
			gap: .5rem;
			align-items: center;
			justify-content: flex-end;
		}

			#factura-global .fg-header-actions .fg-pagination {
				margin: 0 !important;
				padding: 0;
				border: 0;
				gap: .5rem;
			}

		#factura-global .fg-footer {
			position: sticky;
			bottom: 0;
			z-index: 3;
			padding: .65rem 1rem;
			background: rgba(255, 255, 255, .96);
			border-top: 1px solid #ced4da;
			box-shadow: 0 -3px 12px rgba(0, 0, 0, .06);
		}

		#factura-global #fg-footer &gt; .row {
			margin: 0;
		}

		#factura-global #fg-footer .card {
			border: 0;
		}

		/* El modal vive fuera del contexto z-index de #shell &gt; main. */
		#fg-confirm {
			z-index: 1060;
		}

		/* El wrapper del resumen debe ocupar todo el ancho disponible del shell,
			 aunque todavía esté dentro del contenedor del módulo durante el render. */
		#factura-global .fg-summary-row,
		#shell-footer .fg-summary-row {
			box-sizing: border-box;
			width: 100% !important;
			max-width: 100% !important;
			flex: 0 0 100% !important;
		}

		/* El .col interno también debe salir del ancho restringido del padre. */
		.fg-summary-row &gt; .col {
			box-sizing: border-box;
			width: 100% !important;
			max-width: 100% !important;
			flex: 0 0 100% !important;
		}

		/* La tarjeta no debe conservar el ancho de una columna anterior del
			 shell; el espacio disponible se reparte dentro de su cuerpo. */
		.fg-summary-row .card,
		.fg-summary-row .card-body {
			box-sizing: border-box;
			width: 100% !important;
			max-width: none !important;
		}

		.fg-summary-row .card-body {
			display: flex !important;
			justify-content: space-between;
			align-items: center;
		}

			.fg-summary-row .card-body &gt; .ms-auto {
				margin-left: auto !important;
				justify-content: flex-end;
				flex-wrap: wrap;
			}

		#shell-footer .fg-summary-row {
			margin: 0;
		}

		#shell-footer.fg-has-summary {
			display: block !important;
			padding: .5rem 1rem !important;
		}

			#shell-footer.fg-has-summary &gt; #page_controls,
			#shell-footer.fg-has-summary &gt; #shell_buttons {
				display: none !important;
			}

		#shell-footer .fg-summary-row .card {
			width: 100%;
			border: 0;
		}

		#shell-footer .fg-summary-row &gt; .col {
			flex: 0 0 100%;
			max-width: 100%;
		}

		#shell-footer .fg-summary-row .card {
			width: 100% !important;
			max-width: none !important;
		}

		#shell-footer .fg-summary-row .card-body {
			display: flex !important;
			justify-content: space-between;
			gap: .5rem 1rem !important;
			align-items: center !important;
			align-content: center;
			min-height: 3rem;
			width: 100%;
		}

		#shell-footer:has(.fg-summary-row),
		#shell-footer .fg-summary-row,
		#shell-footer .fg-summary-row &gt; .col,
		#shell-footer .fg-summary-row .card {
			align-items: center !important;
			align-self: center !important;
		}

		#shell-footer .fg-summary-row,
		#shell-footer .fg-summary-row &gt; .col,
		#shell-footer .fg-summary-row .card,
		#shell-footer .fg-summary-row .card-body,
		#shell-footer .fg-summary-row .card-body &gt; .ms-auto {
			margin-block: 0 !important;
			align-self: center !important;
		}

		#shell-footer .fg-summary-row,
		#shell-footer .fg-summary-row &gt; .col,
		#shell-footer .fg-summary-row .card,
		#shell-footer .fg-summary-row .card-body {
			height: 100% !important;
		}

		#shell-footer .fg-summary-row .card-body &gt; * {
			align-self: center !important;
			vertical-align: middle;
		}

		.fg-summary-row .card-body &gt; * {
			align-self: center !important;
		}

			#shell-footer .fg-summary-row .card-body &gt; .ms-auto {
				justify-self: end;
				margin-left: 0 !important;
				margin-left: auto !important;
				justify-content: flex-end;
				flex-wrap: wrap;
			}

		@media (max-width: 1100px) {
			#shell-footer .fg-summary-row .card-body &gt; .ms-auto {
				justify-self: start;
				margin-left: 0 !important;
			}
		}

		#shell-footer .fg-pagination {
			width: 100%;
			margin: .5rem 0 0 !important;
			padding-top: .5rem;
			border-top: 1px solid #dee2e6;
		}

		#factura-global .fg-footer-summary {
			display: flex;
			flex-wrap: wrap;
			gap: .75rem 1.25rem;
			align-items: center;
		}

		#factura-global .cursor-pointer {
			cursor: pointer;
		}

		#factura-global .fg-status {
			cursor: pointer;
		}

		#fg-ticket-dialog {
			width: min(52rem, calc(100% - 2rem));
			max-height: calc(100% - 2rem);
		}

		#fg-ticket-dialog::backdrop { background: rgba(0, 0, 0, .5); }

		/* Renglones internos de cada ticket: productos, impuestos y pagos. */
		#factura-global #fg-tbody td {
			vertical-align: top;
		}

			#factura-global #fg-tbody td.ticket-detail-cell {
				padding: 0 !important;
			}

		#factura-global .ticket-detail-table {
			width: 100%;
			min-width: 36rem;
			margin: 0;
			table-layout: fixed;
			border-collapse: collapse;
		}

			#factura-global .ticket-detail-table td {
				padding: .18rem .3rem;
				vertical-align: top;
				line-height: 1.34;
				border-bottom: 1px solid #edf0f4;
			}

			#factura-global .ticket-detail-table .ticket-detail-product {
				width: 44%;
				overflow-wrap: anywhere;
				word-break: break-word;
			}

			#factura-global .ticket-detail-table .ticket-detail-money {
				width: 14%;
				white-space: nowrap;
				text-align: right;
			}

			#factura-global .ticket-detail-table tbody tr:nth-child(odd) td {
				background: rgba(13, 110, 253, .035);
			}

			#factura-global .ticket-detail-table .ticket-total-row td {
				border-top: 2px solid #9aa6b2;
				border-bottom: 0;
				background: #f5f7fa;
				font-weight: 700;
			}

		#factura-global .ticket-line,
		#factura-global .ticket-payment-line {
			min-height: 1.7rem;
			padding: .18rem .3rem;
			line-height: 1.34;
			border-bottom: 1px solid #edf0f4;
		}

			#factura-global .ticket-line:nth-child(odd) {
				background: rgba(13, 110, 253, .035);
			}

		#factura-global .ticket-payment-option {
			cursor: pointer;
			display: block;
			flex: 1 1 auto;
		}

		#factura-global .ticket-payment-radio {
			align-items: center;
			cursor: pointer;
			display: flex;
			gap: .35rem;
			margin: 0;
			width: 100%;
		}

		#factura-global .ticket-payment-radio input {
			margin: 0;
		}

		#factura-global .ticket-payment-list {
			list-style: none;
			margin: 0;
			padding: 0;
		}

		#factura-global .ticket-payment-line {
			align-items: center;
		}

		#factura-global .ticket-payment-line.is-selected {
			font-weight: 600;
			background: rgba(13, 110, 253, .06);
		}

		#factura-global .ticket-total-line {
			min-height: 1.9rem;
			margin-top: 0;
			padding: .3rem;
			line-height: 1.3;
			border-top: 2px solid #9aa6b2;
			background: #f5f7fa;
			font-weight: 700;
		}

		#shell &gt; main {
			padding-inline: 4rem;
		}
	</style>

	<div id="top-loader"/>
	<!-- Filtros, tabla y paginación -->
	<div class="fg-content">
		<div class="fg-layout">
			<autofactura-filters id="fg-filter-anchor" prefix="fg"/>
			<section class="fg-main">
				<header class="toolbar">
					<div class="container-fluid py-3">
						<div class="d-flex flex-wrap gap-2 align-items-end">
							<div class="me-auto">
								<h1 class="h5 mb-0"><xsl:choose><xsl:when test="$cliente">Factura cliente</xsl:when><xsl:otherwise>Factura global — selección de tickets</xsl:otherwise></xsl:choose></h1>
								<small class="text-muted"><xsl:choose><xsl:when test="$cliente">Selecciona un ticket e indica el RFC del receptor.</xsl:when><xsl:otherwise>Filtra, selecciona y factura los tickets no facturados</xsl:otherwise></xsl:choose></small>
							</div>
							<div id="fg-header-actions" class="fg-header-actions"/>
						</div>

					</div>
				</header>
				<div id="fg-data-binding">
					<footer id="fg-footer" class="fg-footer mb-3" aria-label="Resumen y acciones de facturación">
						<div class="row g-3 align-items-center mb-2 fg-summary-row">
							<div class="col">
								<div class="card-body py-2 d-flex flex-wrap gap-3 align-items-center">
									<div class="ms-auto d-flex gap-2">
										<xsl:if test="not($cliente)">
										<button id="fg-btn-unselect-all" class="btn btn-light btn-sm">Quitar todos</button>
										<button id="fg-btn-select-all" class="btn btn-light btn-sm">Seleccionar todos</button>
										<button id="fg-btn-unselect-visible" class="btn btn-light btn-sm">Quitar visibles</button>
										<button id="fg-btn-select-visible" class="btn btn-light btn-sm">Seleccionar visibles</button>
										</xsl:if>
										<button id="fg-btn-clear" class="btn btn-outline-secondary btn-sm" disabled="disabled">Borrar selección</button>
									</div>
									<div class="ms-auto d-flex gap-3">
										<div><strong>Tickets:</strong> <span id="fg-ticketcount">0</span></div>
										<div><strong>Seleccionados:</strong> <span id="fg-sel-count">0</span></div>
										<div><strong>Subtotal:</strong> <span id="fg-sum-subtotal">$0.00</span></div>
										<div><strong>IVA:</strong> <span id="fg-sum-iva">$0.00</span></div>
										<div><strong>IEPS:</strong> <span id="fg-sum-ieps">$0.00</span></div>
										<div><strong>Total:</strong> <span id="fg-sum-total" class="fw-semibold">$0.00</span></div>
										<button id="fg-btn-invoice" class="btn btn-primary btn-sm" disabled="disabled"><xsl:choose><xsl:when test="$cliente">Facturar ticket</xsl:when><xsl:otherwise>Facturar selección</xsl:otherwise></xsl:choose></button>
										<xsl:if test="not($cliente)"><button id="fg-btn-prefactura" class="btn btn-outline-primary btn-sm" disabled="disabled">Generar pre-factura</button></xsl:if>
									</div>
								</div>
							</div>
						</div>
					</footer>

					<div class="fg-pagination d-flex justify-content-between align-items-center mt-3">
						<small class="text-muted" id="fg-page-info" aria-live="polite">Página 1</small>
						<div class="btn-group">
							<button id="fg-btn-prev" class="btn btn-outline-secondary btn-sm">Anterior</button>
							<button id="fg-btn-next" class="btn btn-outline-secondary btn-sm">Siguiente</button>
						</div>
					</div>

					<template id="fg-ticket-dialog-template">
						<dialog id="fg-ticket-dialog" aria-labelledby="fg-ticket-dialog-title" class="shell-dialog rounded border shadow p-0">
							<header class="d-flex justify-content-between align-items-center border-bottom p-3">
								<h2 id="fg-ticket-dialog-title" class="h5 mb-0">Ticket</h2>
								<form method="dialog"><button type="submit" class="btn-close" aria-label="Cerrar ticket"></button></form>
							</header>
							<div id="fg-ticket-full" class="shell-dialog__layout" xo-source="#facturas" xo-stylesheet="/reportes/portal_factura_global_detalle.xslt"></div>
						</dialog>
					</template>
					<div class="table-responsive">
						<div id="fg-ticket-table" xo-source="#facturas" xo-stylesheet="/reportes/portal_factura_global_tickets.xslt?v=20261123_1">
							<p role="status">Cargando tickets&#8230;</p>
						</div>
					</div>
				</div>
			</section>
		</div>
	</div>

	<script><![CDATA[
	globalThis.autofactura = globalThis.autofactura || {};
	const fgFiltersReady = autofactura.mountTicketFilters(document.getElementById('fg-filter-anchor'), {
		prefix: 'fg', applyId: 'fg-btn-apply', resetId: 'fg-btn-reset',
		helpText: 'Solo cambia el detalle mostrado; la facturación siempre toma el ticket completo.'
	});
	autofactura.fg = autofactura.fg || {};
	autofactura.fg.isValidRfc = function isValidRfc(value) {
		const rfc = String(value || '').trim().toUpperCase();
		return rfc === 'XAXX010101' || rfc === 'XAXX010101000' || rfc === 'XEXX010101000' ||
			/^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$/.test(rfc);
	};
	autofactura.fg.isClientRfc = value => /^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$/.test(value.toUpperCase()) && !['XAXX010101000', 'XEXX010101000'].includes(value.toUpperCase());
	autofactura.fg.invoiceRecipientLabel = value => {
		const recipient = String(value || '').trim();
		const rfc = recipient.toUpperCase();
		if (!rfc || rfc === 'FACTURADO') return 'Sin receptor registrado';
		if (['XAXX010101000', 'XAXX010101'].includes(rfc)) return 'Público en general · ' + rfc;
		return recipient;
	};
	autofactura.fg.updateConfirmationMode = function updateConfirmationMode() {
		const fg = autofactura.fg;
		const modal = document.getElementById('fg-confirm');
		if (!modal) return;
		const manualId = fg.pendingStatusTicketId;
		const action = fg.pendingStatusAction;
		const ticket = manualId ? fg.allTickets?.find(item => item.id == manualId) : null;
		const context = fg.getInvoiceContext?.();
		const rfc = document.getElementById('fg-cfdi-rfc')?.value?.trim() || '';
		const clientInvoice = document.getElementById('factura-global')?.dataset.modo === 'cliente';
		const validRfc = clientInvoice ? fg.isClientRfc(rfc) : fg.isValidRfc(rfc);
		const rfcField = modal.querySelector('#fg-cfdi-rfc')?.closest('.col-12');
		const heading = modal.querySelector('.modal-body h2');
		const message = modal.querySelector('.modal-body p');
		const button = modal.querySelector('#fg-m-confirm');
		const title = modal.querySelector('.modal-title');
		const recipient = modal.querySelector('#fg-m-current-receptor');
		recipient.hidden = clientInvoice || action !== 'unmark';
		recipient.querySelector('dd').textContent = recipient.hidden ? '' : fg.invoiceRecipientLabel(ticket?.receptor);
		if (clientInvoice) {
			if (title) title.textContent = 'Confirmar factura cliente';
			if (button) { button.textContent = 'Sí, facturar'; button.disabled = !validRfc; }
			if (message) message.textContent = 'Se generará un token para emitir la factura del ticket en Contpaqi.';
			return;
		}
		if (action === 'unmark') {
			if (title) title.textContent = 'Quitar marca de facturado';
			if (button) button.textContent = 'Quitar marca';
			if (message) message.textContent = 'Se quitará la marca de facturado y el ticket volverá a estar disponible.';
			if (heading) heading.textContent = 'Confirmar cambio de estado';
			if (rfcField) rfcField.hidden = true;
			return;
		}
		const count = ticket ? 1 : (context?.selectedTickets.length || 0);
		const total = ticket ? ticket.total : (context?.totals.total || 0);
		const totalText = Number(total).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
		if (title) title.textContent = validRfc
			? (ticket ? 'Confirmar factura del ticket' : 'Confirmar factura global')
			: (ticket ? 'Marcar ticket como facturado' : 'Guardar estado de tickets');
		if (button) button.textContent = validRfc ? 'Sí, facturar' : (ticket ? 'Marcar como facturado' : 'Guardar cambios');
		if (message) message.textContent = validRfc
			? `Se facturarán ${count} tickets por ${totalText}. Se generará un token para continuar en Contpaqi.`
			: `Se guardarán ${count} tickets como facturados para «${rfc || '(sin receptor)'}». No se generará token porque el texto no tiene formato de RFC válido.`;
		if (heading) heading.textContent = validRfc ? 'Parámetros de la factura' : 'Datos del marcado manual';
		if (rfcField) rfcField.hidden = false;
	};

		autofactura.fg.confirm_invoice_creation = async function confirm_invoice_creation() {
			const fg = autofactura.fg;
			const manualTicketId = fg?.pendingStatusTicketId || null;
			const statusAction = fg?.pendingStatusAction || 'mark';
			const clientInvoice = document.getElementById('factura-global')?.dataset.modo === 'cliente';
			if (!document.getElementById('factura-global')) return;
			if (clientInvoice && (manualTicketId || fg?.selected?.size !== 1)) return;
			if (!fg || fg.invoiceInProgress || (!manualTicketId && (!fg.selected || fg.selected.size === 0))) return;
			fg.invoiceInProgress = true;
			const confirmButton = document.getElementById('fg-m-confirm');
			if (confirmButton) confirmButton.disabled = true;
			//const payload = new File([JSON.stringify({
			//	 ticketIds: Array.from(selected),
			//	 cfdi: {
			//			rfc: $('fg-cfdi-rfc').value.trim(),
			//			uso: $('fg-cfdi-uso').value,
			//			metodo: $('fg-cfdi-metodo').value,
			//			forma: $('fg-cfdi-forma').value
			//	 }
			//})], "@xml", { type: "text/plain" });
			fg.showLoader(true);
			try {
				bootstrap.Modal.getInstance(document.querySelector('#fg-confirm')).hide();
				if (manualTicketId) {
					const ticket = fg.allTickets.find(item => item.id == manualTicketId);
					if (!ticket) throw new Error('No se encontró el ticket seleccionado.');
					let result;
					if (statusAction === 'unmark') {
						const payload = xover.xml.createDocument('<tickets action="unmark"><row id="' + String(ticket.sourceId).replaceAll('&', '&amp;').replaceAll('"', '&quot;') + '"/></tickets>');
						result = await xover.server.facturar(new File([payload], '@xml', { type: 'text/xml' }));
						ticket.receptor = '';
					} else {
						const receptor = document.getElementById('fg-cfdi-rfc')?.value?.trim() || '';
						if (!receptor) throw new Error('Indica el RFC o receptor para marcar el ticket como facturado.');
						const payload = fg.buildInvoiceXml([manualTicketId], receptor);
						result = await xover.server.facturar(new File([payload], '@xml', { type: 'text/xml' }));
						const codigo = fg.isValidRfc(receptor) ? result.documentElement?.getAttribute('token') : null;
						ticket.receptor = receptor;
						fg.selected.delete(manualTicketId);
						fg.pendingStatusTicketId = null;
						fg.pendingStatusAction = null;
						fg.applyFilters();
						alert(codigo
							? `El ticket quedó marcado para ${receptor}. Continúa en el archivo de Contpaqi con el código ${codigo}.`
							: `Se guardó el cambio. El ticket quedó marcado como facturado para ${receptor}; no se generó token porque el valor no tiene formato de RFC válido.`);
						return;
					}
					fg.selected.delete(manualTicketId);
					fg.pendingStatusTicketId = null;
					fg.pendingStatusAction = null;
					fg.applyFilters();
					alert(statusAction === 'unmark' ? 'Se quitó la marca de facturado; el ticket volvió a estar disponible.' : `El ticket quedó marcado como facturado para ${ticket.receptor}.`);
				} else {
					const receptor = document.getElementById('fg-cfdi-rfc')?.value?.trim() || '';
					if (!receptor) throw new Error('Indica el RFC o receptor para procesar los tickets seleccionados.');
					if (clientInvoice && !fg.isClientRfc(receptor)) {
						xo.dom.alert('Indica el RFC del cliente para emitir la factura.');
						return;
					}
					const requestedIds = [...fg.selected];
					const payload = fg.buildInvoiceXml(requestedIds, clientInvoice ? receptor.toUpperCase() : receptor);
					const result = await xover.server.facturar(new File([payload], "@xml", { type: "text/xml" }));
					const responseRows = [...result.getElementsByTagName('row')];
					const updatedIds = new Set(responseRows.map(row => String(row.getAttribute('id') || '').toLowerCase()));
					const missingIds = requestedIds.filter(id => !updatedIds.has(String(fg.allTickets.find(ticket => ticket.id == id)?.sourceId || '').toLowerCase()));
					if (missingIds.length) {
						alert(`El servidor confirmó ${updatedIds.size} de ${requestedIds.length} tickets. Se conservó la selección; verifica el procedimiento almacenado antes de reintentar.`);
						return;
					}
					const codigo = fg.isValidRfc(receptor) ? result.documentElement?.getAttribute('token') : null;
					for (const row of responseRows) {
						const ticket = fg.allTickets.find(item => item.id == row.getAttribute('id'));
						if (ticket) ticket.receptor = receptor;
					}
					fg.selected.clear(); fg.applyFilters();
					alert(codigo
						? `Puede continuar en el archivo de Contpaqi con el siguiente código: ${codigo}`
						: `Se guardaron los cambios. Los tickets quedaron marcados como facturados para ${receptor}; no se generó token porque el valor no tiene formato de RFC válido.`);
				}
			} catch (err) {
				if (instanceOf.call(err, Error)) return Promise.reject(err);
				let message = instanceOf.call(err.document, Node) && err.document.single(`//xo:message`) || "Error al facturar. Revisa el endpoint.";
				console.error(err);
				alert(message.textContent || message);
			} finally {
				fg.invoiceInProgress = false;
				if (confirmButton) confirmButton.disabled = false;
				fg.showLoader(false);
			}
		};
		if (!autofactura.fg.confirmListenerBound) {
			xo.listener.on(`click::#fg-m-confirm`, autofactura.fg.confirm_invoice_creation);
			autofactura.fg.confirmListenerBound = true;
		}
		//const autofactura = {};
		(function () {
			const root = document.getElementById('factura-global');
			const clientInvoice = root.dataset.modo === 'cliente';
			const isCurrent = () => root?.isConnected && document.getElementById('factura-global') === root;
			const PAGE_SIZE = 50;
			const fg = autofactura.fg;

			const ticketsStore = xo.stores['#facturas'];
			const viewNamespace = 'http://panax.io/state';
			fg.viewEvents?.abort();
			const { signal } = fg.viewEvents = new AbortController();
			fg.allTickets = [];
			fg.filtered = [];
			// Selection lives on #facturas rows as state:selected.
			fg.selected = autofactura.ticketSelection;
			fg.invoiceInProgress = false;
			fg.pendingStatusTicketId = null;
			fg.pendingStatusAction = null;

			let allTickets = fg.allTickets, filtered = fg.filtered, selected = fg.selected;
			function showLoader(on) {
				const el = document.getElementById('top-loader');
				if (!el) return;
				el.style.width = on ? '80%' : '100%';
				if (!on) setTimeout(() => { el.style.width = '0%'; }, 300);
			}
			const $ = (id) => document.getElementById(id);
			const numberValue = (value, fallback = 0) => {
				const number = Number(value);
				return Number.isFinite(number) ? number : fallback;
			};
			const roundMoney = (value) => Math.round((numberValue(value) + Number.EPSILON) * 100) / 100;
			const rateValue = (value, fallback = 0) => {
				const rate = numberValue(value, fallback);
				return Math.abs(rate) > 1 ? rate / 100 : rate;
			};
			const attrNumber = (row, names, fallback = 0) => {
				for (const name of names) {
					const attr = row.getAttributeNode(name);
					if (attr && attr.value !== '') return numberValue(attr.value, fallback);
				}
				return fallback;
			};
			const attrRate = (row, names, fallback = 0) => {
				for (const name of names) {
					const attr = row.getAttributeNode(name);
					if (attr && attr.value !== '') return rateValue(attr.value, fallback);
				}
				return fallback;
			};
			const escapeHtml = (value) => String(value ?? '')
				.replaceAll('&', '&amp;')
				.replaceAll('"', '&quot;')
				.replaceAll('<', '&lt;')
				.replaceAll('>', '&gt;');

			function readTickets(model, rows) {
				if (model.documentElement?.localName !== 'model') throw new Error('Respuesta de tickets no válida');
				return Array.from(rows ?? model.querySelectorAll('model > row, model > selected-tickets > row'), row => {
					const i = row.getAttribute("id");
					const d = row.getAttribute("dt").parseDate();
					const subtotal = roundMoney(row.getAttribute("st"));
					const tasaIVA = attrRate(row, ["tasaIVA", "iva_tasa", "tasa"], 0.16);
					const tasaIEPS = attrRate(row, ["tasaIEPS", "ieps_tasa"], 0);
					const itemNodes = row.select('items/item') || row.select('item') || [];
					const items = [...itemNodes].map(item => ({

						codigo: item.getAttribute('codigo') || '',
						cantidad: attrNumber(item, ['cantidad', 'quantity'], 0),
						base: attrNumber(item, ['base', 'subtotal'], NaN),
						unidad: item.getAttribute('unidad') || '',
						claveUnidad: item.getAttribute('clave_unidad') || '',
						claveProducto: item.getAttribute('clave_producto_servicio') || item.getAttribute('clave_sat') || '',
						descripcion: item.getAttribute('descripcion') || '',
						precioArticulo: roundMoney(item.getAttribute('precio_articulo')),
						precioExtras: roundMoney(item.getAttribute('precio_extras')),
						importe: roundMoney(item.getAttribute('importe')),
						tasaIVA: attrRate(item, ['tasa_iva'], tasaIVA),
						tasaIEPS: attrRate(item, ['tasa_ieps'], tasaIEPS),
						iva: roundMoney(attrNumber(item, ['iva'], 0)),
						ieps: roundMoney(attrNumber(item, ['ieps'], 0))
					}));
					const ivaFromXml = attrNumber(row, ["iva", "iva_total"], NaN);
					const iepsFromXml = attrNumber(row, ["ieps", "ieps_total"], NaN);
					const iva = Number.isFinite(ivaFromXml) ? roundMoney(ivaFromXml) : roundMoney(items.reduce((sum, item) => sum + item.iva, 0) || subtotal * tasaIVA);
					const ieps = Number.isFinite(iepsFromXml) ? roundMoney(iepsFromXml) : roundMoney(items.reduce((sum, item) => sum + item.ieps, 0) || subtotal * tasaIEPS);
					const totalFromXml = attrNumber(row, ["total"], NaN);
					const total = Number.isFinite(totalFromXml) ? roundMoney(totalFromXml) : roundMoney(subtotal + iva + ieps);
					const formaPago = row.getAttribute("fp") || '';
					const formaPagoSugerida = row.getAttribute("fp_sugerida") || '';
					const paymentNodes = row.select('payments/payment') || row.select('payments/pago') || [];
					const pagos = [...paymentNodes].map(payment => ({

						formaPago: payment.getAttribute('forma_pago') || payment.getAttribute('forma') || payment.getAttribute('fp') || '',
						monto: roundMoney(payment.getAttribute('monto'))
					})).filter(payment => payment.formaPago);
					const formasPago = [...new Set(pagos.map(payment => payment.formaPago))];
					if (!formasPago.length && formaPago) formasPago.push(formaPago);
					return {
						id: i,
						sourceId: row.getAttribute("id") || '',

						cliente: row.getAttribute("cte") || '',
						origenDatos: row.getAttribute("od") || '',
						get receptor() { return row.getAttribute('receptor') || ''; },
						set receptor(value) {
							if (value) row.setAttribute('receptor', value);
							else row.removeAttribute('receptor');
						},
						outsideQuery: row.parentNode.localName === 'selected-tickets',
						fecha: d.toISOString().slice(0, 10), fechaHora: row.getAttribute("dt"), folio: row.getAttribute("tkt"),
						sucursal: row.getAttribute("suc"),
						get formaPago() { return row.getAttribute('fp') || ''; },
						formaPagoSugerida, formasPago, pagos, pagosDetallados: paymentNodes.length > 0,
						subtotal, tasaIVA, tasaIEPS, iva, ieps, total, items,
						get estado() { return this.receptor ? 'Facturado' : 'No facturado'; }
					};
				});
			}

			function populatePaymentFilter() {
				const select = $('fg-f-formapago');
				const value = select.value;
				const forms = [...new Set([value, ...Array.from(select.options, option => option.value), ...allTickets.flatMap(ticket => ticket.formasPago || [])].filter(Boolean))]
					.sort((a, b) => a.localeCompare(b, 'es'));
				select.innerHTML = '<option value="">Todos</option>' +
					forms.map(form => '<option value="' + escapeHtml(form) + '">' + escapeHtml(form) + '</option>').join('');
				if ([...select.options].some(option => option.value === value)) select.value = value;
			}

			let authorizedClients = [];
			let recipientFilterSupported = false;

			function populateBranchFilter(value = $('fg-f-sucursal').value) {
				const select = $('fg-f-sucursal');
				const client = $('fg-f-cliente').value;
				const branches = new Set(authorizedClients
					.filter(node => !client || node.getAttribute('id') === client)
					.flatMap(node => [...node.querySelectorAll('sucursal')].map(branch => branch.getAttribute('nombre'))));
				select.replaceChildren(new Option('Todas', ''), ...[...branches]
					.sort((a, b) => a.localeCompare(b, 'es')).map(branch => new Option(branch, branch)));
				select.value = branches.has(value) ? value : '';
				select.disabled = !branches.size;
			}

			function populateRecipientFilter(value = $('fg-f-receptor').value) {
				const select = $('fg-f-receptor');
				const client = $('fg-f-cliente').value;
				const branch = $('fg-f-sucursal').value;
				const recipients = new Set(authorizedClients
					.filter(node => !client || node.getAttribute('id') === client)
					.flatMap(node => [...node.querySelectorAll('receptor')]
						.filter(node => !branch || node.getAttribute('sucursal') === branch)
						.map(node => node.getAttribute('valor')).filter(Boolean)));
				select.replaceChildren(new Option('Todos', ''), ...[...recipients]
					.sort((a, b) => a.localeCompare(b, 'es'))
					.map(recipient => new Option(autofactura.fg.invoiceRecipientLabel(recipient), recipient)));
				select.value = recipientFilterSupported && recipients.has(value) ? value : '';
				select.disabled = !recipientFilterSupported || !recipients.size;
				const help = select.parentElement.querySelector('.form-text');
				help.hidden = !select.disabled;
				help.textContent = recipientFilterSupported ? 'No hay receptores registrados para esta selección.'
					: 'El filtro de receptor no está disponible en el servidor.';
			}

			async function loadFilterCatalog() {
				const client = $('fg-f-cliente');
				$('fg-f-sucursal').disabled = true;
				try {
					const context = xo.xml.createDocument('<model/>');
					const params = new URLSearchParams({
						FROM: 'autofactura.portalTickets',
						'@xml': '<query catalogo="filtros"/>'
					});
					const response = await xo.server.request.call(context, params,
						new Headers({ Accept: 'application/xml, text/xml', 'X-Page-Index': '1', 'X-Page-Size': '50' }), { cache: 'no-store' });
					if (!isCurrent()) return;
					if (response?.documentElement?.localName !== 'catalogo') throw new Error('Catálogo de empresas no válido.');
					recipientFilterSupported = response.documentElement.getAttribute('filtroReceptor') === '1';
					authorizedClients = [...response.documentElement.querySelectorAll(':scope > cliente')];
					client.replaceChildren(new Option(authorizedClients.length ? 'Todos' : 'Sin empresas autorizadas', ''),
						...authorizedClients.map(node => new Option(node.getAttribute('nombre'), node.getAttribute('id'))));
					client.disabled = !authorizedClients.length;
				} catch (error) {
					if (!isCurrent()) return;
					client.replaceChildren(new Option('No se pudieron cargar las empresas', ''));
					console.error('Factura Global:', error?.message || error?.status || error);
				}
			}

			function resetFilterValues() {
				['fg-f-start', 'fg-f-end', 'fg-f-folio', 'fg-f-cliente', 'fg-f-sucursal', 'fg-f-formapago', 'fg-f-producto', 'fg-f-pago-unico', 'fg-f-impuestos'].forEach(id => $(id).value = '');
				$('fg-f-incluir-productos').checked = false;
				populateBranchFilter('');
				populateRecipientFilter('');
				$('fg-f-estado').value = 'No facturado';
				$('fg-f-min').value = '0.00';
				$('fg-f-max').value = '9999.99';
			}

			function money(n) { return n.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' }); }
			function detailMoney(n) { return Number(n) === 0 ? '' : money(n); }
			function setText(id, value) {
				const element = $(id);
				if (element) element.textContent = value;
			}

			function updateFilterIndicators() {
				autofactura.updateTicketFilterIndicators($('fg-sidebar'), 'fg');
			}

			let committedFilters;
			const readFilterDraft = () => ({
				...Object.fromEntries([...autofactura.ticketFilterNames, 'cliente', 'receptor'].map(name => [name, $('fg-f-' + name).value])),
				'incluir-productos': $('fg-f-incluir-productos').checked
			});

			function applyFilters() {
				updateFilterIndicators();
				showLoader(true);
				const fstart = committedFilters.start;
				const fend = committedFilters.end;
				const ffolios = committedFilters.folio
					.split(',')
					.map(folio => folio.trim().toLowerCase())
					.filter(Boolean);
				const fformaPago = committedFilters.formapago.trim().toLowerCase();
				const fproductos = autofactura.parseTicketFilterTerms(committedFilters.producto);
				const fpagoUnico = committedFilters['pago-unico'];
				const fimpuestos = committedFilters.impuestos;
				const festado = committedFilters.estado;
				const fmin = committedFilters.min === '0.00' ? NaN : parseFloat(committedFilters.min);
				const fmax = committedFilters.max === '9999.99' ? NaN : parseFloat(committedFilters.max);
				filtered = allTickets.filter(t => {
					if (t.outsideQuery) return false;
					if (festado && t.estado !== festado) return false;
					if (fstart && t.fecha < fstart) return false;
					if (fend && t.fecha > fend) return false;
					if (!isNaN(fmin) && t.total < fmin) return false;
					if (!isNaN(fmax) && t.total > fmax) return false;
					if (ffolios.length) {
						const hay = (t.folio || '').toLowerCase();
						if (!ffolios.some(folio => hay.includes(folio))) return false;
					}
					if (fformaPago) {
						const hay = (t.formasPago || [t.formaPago]).some(forma => forma.toLowerCase() === fformaPago);
						if (!hay) return false;
					}
					if (fproductos.length) {
						const hay = t.items.some(item => productMatches(item, fproductos));
						if (!hay) return false;
					}
					if (fpagoUnico) {
						/* Sin detalle de pagos no se puede afirmar que el ticket sea de pago único. */
						if (!t.pagosDetallados || (fpagoUnico === '1' && t.formasPago.length !== 1) || (fpagoUnico === '0' && t.formasPago.length <= 1)) return false;
					}
					if (fimpuestos === 'iva' && t.iva <= 0) return false;
					if (fimpuestos === 'ieps' && t.ieps <= 0) return false;
					if (fimpuestos === 'ambos' && (t.iva <= 0 || t.ieps <= 0)) return false;
					if (fimpuestos === 'ninguno' && (t.iva > 0 || t.ieps > 0)) return false;
					return true;
				});
				render();
				showLoader(false)
			}

			function pageItems() {
				return filtered;
			}

			function productMatches(item, terms) {
				const text = (item.codigo + ' ' + item.descripcion).toLowerCase();
				return terms.some(term => text.includes(term));
			}

			function render() {
				if (!isCurrent()) return;
				const model = ticketsStore.document;
				const page = model.createElementNS(viewNamespace, 'state:factura-global');
				const rows = pageItems();
				const terms = autofactura.parseTicketFilterTerms(committedFilters.producto);
				const onlyMatchingProducts = terms.length > 0 && !committedFilters['incluir-productos'];
				page.setAttribute('productos-filtrados', String(onlyMatchingProducts));

				function append(parent, name, attributes) {
					const node = model.createElementNS(null, name);
					for (const [key, value] of Object.entries(attributes)) node.setAttribute(key, value);
					parent.appendChild(node);
					return node;
				}

				for (const ticket of rows) {
					const node = append(page, 'ticket', {
						id: ticket.id, fecha: ticket.fecha, subtotal: money(ticket.subtotal),
						iva: money(ticket.iva), ieps: money(ticket.ieps), total: money(ticket.total)
					});
					const items = onlyMatchingProducts ? ticket.items.filter(item => productMatches(item, terms)) : ticket.items;
					for (const item of items) append(node, 'item', {
						descripcion: item.descripcion || item.codigo, subtotal: detailMoney(item.importe),
						iva: detailMoney(item.iva), ieps: detailMoney(item.ieps), total: detailMoney(item.importe + item.iva + item.ieps)
					});
					for (const payment of ticket.pagos) append(node, 'payment', { forma: payment.formaPago, monto: money(payment.monto) });
				}
				const previous = model.documentElement.getElementsByTagNameNS(viewNamespace, 'factura-global')[0];
				if (previous) previous.replaceWith(page);
				else model.documentElement.appendChild(page);
				$('fg-ticket-table').render()
					.then(() => { if (isCurrent()) fg.refreshSelection(); })
					.catch(error => console.error('Factura Global:', error));

				const { index, size, total } = pageMetadata(model);
				const totalPages = Math.max(1, Math.ceil(total / (size || PAGE_SIZE)));
				const loaded = model.documentElement.querySelectorAll(':scope > row').length;
				const visible = filtered.length < loaded ? ' · ' + filtered.length + ' visibles en esta página' : '';
				const pendingFilters = xo.state.fgFiltersPending || !sameFilters(queryFilters(), appliedFilters(model.documentElement));
				$('fg-page-info').textContent = loadingQuery ? 'Buscando tickets…' :
					'Página ' + (index || 1) + ' de ' + totalPages + ' · ' + total + ' tickets según la consulta' + visible;
				$('fg-btn-prev').disabled = loadingQuery || pendingFilters || index <= 1;
				$('fg-btn-next').disabled = loadingQuery || pendingFilters || index >= totalPages;
				updateSummary(); updateButtons();
			}

			function updateSummary() {
				let subtotal = 0, iva = 0, ieps = 0, total = 0;
				for (const id of selected) {
					const t = allTickets.find(x => x.id == id); if (!t) continue;
					subtotal += t.subtotal; iva += t.iva; ieps += t.ieps; total += t.total;
				}
				setText('fg-ticketcount', selected.size);
				setText('fg-sum-subtotal', money(subtotal));
				setText('fg-sum-iva', money(iva));
				setText('fg-sum-ieps', money(ieps));
				setText('fg-sum-total', money(total));
				setText('fg-sel-count', selected.size);
				setText('fg-m-count', selected.size);
				setText('fg-m-total', money(total));
			}

			function updateButtons() {
				const has = clientInvoice ? selected.size === 1 : selected.size > 0;
				const clearButton = $('fg-btn-clear');
				const invoiceButton = $('fg-btn-invoice');
				if (clearButton) clearButton.disabled = !has;
				if (invoiceButton) invoiceButton.disabled = !has;
				const preinvoiceButton = $('fg-btn-prefactura');
				if (preinvoiceButton) preinvoiceButton.disabled = !has;
			}

			function attachShellFooter() {
				const moduleFooter = $('fg-footer');
				const shellFooter = $('shell-footer') || document.querySelector('#shell > footer');
				if (!(shellFooter && moduleFooter.hasChildNodes())) return;
				shellFooter.replaceContent(...moduleFooter.childNodes)
				//const summary = moduleFooter?.querySelector('.fg-summary-row');
				//if (!shellFooter) return;
				//shellFooter.classList.add('fg-has-summary');

				//const summaries = [...shellFooter.querySelectorAll('.fg-summary-row')];
				//const shellSummary = summaries[0] || null;
				//summaries.slice(1).forEach(node => node.remove());
				//if (summary && summary !== shellSummary) {
				//	if (shellSummary) summary.remove();
				//	else shellFooter.appendChild(summary);
				//}

				//if (moduleFooter && !moduleFooter.querySelector('.fg-summary-row') && !moduleFooter.querySelector('.fg-pagination')) {
				//	moduleFooter.remove();
				//}
			}

			function attachHeaderPagination() {
				const headerActions = $('fg-header-actions');
				const pagination = document.querySelector('#fg-data-binding .fg-pagination');
				if (headerActions && pagination && pagination.parentElement !== headerActions) {
					headerActions.appendChild(pagination);
				}
			}

			function xmlAttr(value) {
				return String(value ?? '')
					.replaceAll('&', '&amp;')
					.replaceAll('"', '&quot;')
					.replaceAll('<', '&lt;')
					.replaceAll('>', '&gt;');
			}

			function selectedTotals(ids = [...selected]) {
				return [...ids].reduce((totals, id) => {
					const ticket = allTickets.find(item => item.id == id);
					if (!ticket) return totals;
					totals.subtotal += ticket.subtotal;
					totals.iva += ticket.iva;
					totals.ieps += ticket.ieps;
					totals.total += ticket.total;
					return totals;
				}, { subtotal: 0, iva: 0, ieps: 0, total: 0 });
			}

			function taxXml(ticket) {
				if (ticket.items.length) return ticket.items.flatMap(item => {
					const taxes = [];
					if (item.iva) taxes.push('<tax type="IVA" rate="' + xmlAttr((item.tasaIVA * 100).toFixed(2)) + '" amount="' + xmlAttr(item.iva.toFixed(2)) + '"/>');
					if (item.ieps) taxes.push('<tax type="IEPS" rate="' + xmlAttr((item.tasaIEPS * 100).toFixed(2)) + '" amount="' + xmlAttr(item.ieps.toFixed(2)) + '"/>');
					return taxes;
				}).join('');
				const taxes = [];
				if (ticket.iva) taxes.push('<tax type="IVA" rate="' + xmlAttr((ticket.tasaIVA * 100).toFixed(2)) + '" amount="' + xmlAttr(ticket.iva.toFixed(2)) + '"/>');
				if (ticket.ieps) taxes.push('<tax type="IEPS" rate="' + xmlAttr((ticket.tasaIEPS * 100).toFixed(2)) + '" amount="' + xmlAttr(ticket.ieps.toFixed(2)) + '"/>');
				return taxes.join('');
			}

			function buildInvoiceXml(ids = [...selected], receptorValue = $('fg-cfdi-rfc').value.trim()) {
				const totals = selectedTotals(ids);
				const rows = [...ids].map(id => {
					const ticket = allTickets.find(item => item.id == id);
					if (!ticket) return '';
					const items = ticket.items.map(item => '<item codigo="' + xmlAttr(item.codigo) +
						'" descripcion="' + xmlAttr(item.descripcion) +
						'" precio_articulo="' + xmlAttr(item.precioArticulo.toFixed(2)) +
						'" precio_extras="' + xmlAttr(item.precioExtras.toFixed(2)) +
						'" importe="' + xmlAttr(item.importe.toFixed(2)) +
						'" tasa_iva="' + xmlAttr((item.tasaIVA * 100).toFixed(2)) +
						'" tasa_ieps="' + xmlAttr((item.tasaIEPS * 100).toFixed(2)) +
						'" iva="' + xmlAttr(item.iva.toFixed(2)) +
						'" ieps="' + xmlAttr(item.ieps.toFixed(2)) + '"/>').join('');
					return '<row id="' + xmlAttr(ticket.sourceId) +
						'" folio="' + xmlAttr(ticket.folio) +
						'" cliente="' + xmlAttr(ticket.cliente) +
						'" origen_datos="' + xmlAttr(ticket.origenDatos) +
						'" forma_pago="' + xmlAttr(ticket.formaPago) +
						'" forma_pago_sugerida="' + xmlAttr(ticket.formaPagoSugerida) +
						'" subtotal="' + xmlAttr(ticket.subtotal.toFixed(2)) +
						'" iva="' + xmlAttr(ticket.iva.toFixed(2)) +
						'" ieps="' + xmlAttr(ticket.ieps.toFixed(2)) +
						'" total="' + xmlAttr(ticket.total.toFixed(2)) +
						'" tasaIVA="' + xmlAttr((ticket.tasaIVA * 100).toFixed(2)) +
						'" tasaIEPS="' + xmlAttr((ticket.tasaIEPS * 100).toFixed(2)) +
						'"><items>' + items + '</items><taxes>' + taxXml(ticket) + '</taxes></row>';
				}).join('');
				const root = xover.xml.createDocument('<tickets version="2" taxModel="ticket-summary">' + rows + '</tickets>');
				for (const [attr, value] of Object.entries({
					receptor: receptorValue,
					conteo: ids.length,
					subtotal: totals.subtotal.toFixed(2),
					iva: totals.iva.toFixed(2),
					ieps: totals.ieps.toFixed(2),
					total: totals.total.toFixed(2),
					tasaIVA: '16.00',
					tasaIEPS: totals.ieps ? '8.00' : '0.00',
					tasa: '16'
				})) root.documentElement.setAttribute(attr, value);
				return root;
			}

			function bindStableSelectionEvents() {
				document.addEventListener('change', (event) => {
					const input = event.target;
					if (input.matches?.('#factura-global #fg-chk-all')) {
						if (clientInvoice) return;
						if (input.checked) {
							selected.setMany(pageItems().filter(row => row.estado === 'No facturado').map(row => row.id), true);
						} else {
							selected.setMany(pageItems().map(row => row.id), false);
						}
						render();
						return;
					}
					if (!input.matches?.('#factura-global #fg-tbody .fg-row')) return;
					const id = input.dataset.id;
					if (!input.checked) selected.delete(id);
					else if (clientInvoice) selected.selectOnly(id);
					else selected.add(id);
					updateSummary();
					updateButtons();
					const rows = pageItems();
					const selectAll = $('#fg-chk-all');
					if (selectAll) {
						selectAll.disabled = rows.length === 0;
						selectAll.checked = rows.length > 0 && rows.every(row => selected.has(row.id));
					}
				}, { signal });
			}

			const metaNamespace = 'http://panax.io/metadata';
			let loadingQuery = false;
			const queryFilters = () => ['start', 'end', 'estado', 'cliente', 'sucursal', 'receptor'].map(name => committedFilters[name]);
			const appliedFilters = root => ['desde', 'hasta', 'estado', 'tenant', 'sucursal', 'receptor'].map(name => root.getAttribute(name) || '');
			const sameFilters = (left, right) => left.every((value, index) => value === right[index]);

			function pageMetadata(model) {
				const root = model.documentElement;
				const read = name => Number(root.getAttributeNS(metaNamespace, name) || root.getAttribute('meta:' + name));
				return { index: read('pageIndex'), size: read('pageSize'), total: read('totalCount') };
			}

			async function requestTickets(index, [desde, hasta, estado, tenant, sucursal, receptor]) {
				const query = xo.xml.createDocument('<query order_by="[@tkt]"/>').documentElement;
				if (desde) query.setAttribute('desde', desde);
				if (hasta) query.setAttribute('hasta', hasta);
				if (!desde && !hasta) query.setAttribute('periodo', 'actual');
				if (estado) query.setAttribute('estado', estado);
				if (tenant) query.setAttribute('tenant', tenant);
				if (sucursal) query.setAttribute('sucursal', sucursal);
				if (receptor) query.setAttribute('receptor', receptor);
				const params = new URLSearchParams({
					FROM: 'autofactura.portalTickets',
					'@xml': new XMLSerializer().serializeToString(query)
				});
				const context = xo.xml.createDocument('<model/>');
				const headers = new Headers({
					Accept: 'application/xml, text/xml',
					'X-Page-Size': String(PAGE_SIZE),
					'X-Page-Index': String(index)
				});
				const response = await xo.server.request.call(context, params, headers, { cache: 'no-store' });
				if (response?.documentElement?.localName !== 'model' ||
					pageMetadata(response).index !== index || pageMetadata(response).size !== PAGE_SIZE) {
					throw new Error('La consulta no devolvió la página de tickets solicitada.');
				}
				return response;
			}

			function replaceTickets(model, response) {
				const root = model.documentElement;
				const rows = [...root.querySelectorAll(':scope > row')];
				const archive = root.querySelector(':scope > selected-tickets') || root.appendChild(model.createElement('selected-tickets'));
				for (const row of rows) {
					if (selected.has(row.getAttribute('id'))) archive.appendChild(row);
					else row.remove();
				}
				const previousSelections = new Map([...archive.children].map(row => [row.getAttribute('id'), row]));
				const fragment = model.createDocumentFragment();
				for (const row of response.documentElement.querySelectorAll(':scope > row')) {
					const id = row.getAttribute('id');
					const imported = model.importNode(row, true);
					const previous = previousSelections.get(id);
					if (previous) {
						if (selected.has(id)) imported.setAttributeNS(viewNamespace, 'state:selected', 'true');
						previous.remove();
					}
					fragment.appendChild(imported);
				}
				if (!archive.children.length) archive.remove();
				root.appendChild(fragment);
				const page = pageMetadata(response);
				root.setAttributeNS(metaNamespace, 'meta:pageIndex', page.index);
				root.setAttributeNS(metaNamespace, 'meta:pageSize', page.size);
				root.setAttributeNS(metaNamespace, 'meta:totalCount', page.total);
				allTickets.splice(0, allTickets.length, ...readTickets(model));
				populatePaymentFilter();
			}

			async function searchTickets(index = 1, force = false) {
				if (loadingQuery) return;
				const model = ticketsStore.document;
				const filters = queryFilters();
				const previous = appliedFilters(model.documentElement);
				if (!force && index === pageMetadata(model).index && sameFilters(filters, previous)) return;
				loadingQuery = true;
				render();
				try {
					const response = await requestTickets(index, filters);
					if (!isCurrent() || ticketsStore.document !== model || !sameFilters(filters, queryFilters())) return;
					const effective = ['desde', 'hasta'].map((name, position) => response.documentElement.getAttribute(name) ?? filters[position]);
					replaceTickets(model, response);
					const modelRoot = model.documentElement;
					modelRoot.setAttribute('desde', effective[0]);
					modelRoot.setAttribute('hasta', effective[1]);
					modelRoot.setAttribute('estado', filters[2]);
					modelRoot.setAttribute('tenant', filters[3]);
					modelRoot.setAttribute('sucursal', filters[4]);
					modelRoot.setAttribute('receptor', filters[5]);
					[committedFilters.start, committedFilters.end] = effective;
					if (!xo.state.fgFiltersPending) {
						$('fg-f-start').value = effective[0];
						$('fg-f-end').value = effective[1];
						autofactura.captureTicketFilters($('fg-sidebar'), 'fg');
					}
				} catch (error) {
					if (isCurrent() && sameFilters(filters, queryFilters())) xo.dom.alert('No se pudo consultar la página de tickets. Vuelve a intentarlo.');
					console.error('Factura Global:', error?.message || error?.status || error);
				} finally {
					loadingQuery = false;
					if (isCurrent()) {
						const current = queryFilters();
						const changed = !sameFilters(current, filters) && !sameFilters(current, appliedFilters(ticketsStore.document.documentElement));
						applyFilters();
						if (changed) searchTickets();
					}
				}
			}

			function bindStablePaginationEvents() {
				document.addEventListener('click', event => {
					const button = event.target.closest?.('#fg-btn-prev, #fg-btn-next');
					if (!button || button.disabled || xo.state.fgFiltersPending) return;
					const { index } = pageMetadata(ticketsStore.document);
					searchTickets(index + (button.id === 'fg-btn-prev' ? -1 : 1));
				}, { signal });
			}

			function bindFilterEvents(aside) {
				const button = $('fg-btn-apply');
				const badge = button.querySelector('[data-filter-countdown]');
				const delay = 3000;
				let timer;
				let lastPointerMove = -Infinity;
				let hovering = matchMedia('(hover: hover)').matches && button.matches(':hover');

				function stopTimer() {
					clearTimeout(timer);
					xo.state.fgFilterSeconds = null;
				}

				function startCountdown() {
					if (hovering || !isCurrent() || !aside.isConnected || !xo.state.fgFiltersPending) return;
					const deadline = performance.now() + delay;
					function tick() {
						if (!isCurrent() || !aside.isConnected || !xo.state.fgFiltersPending) return;
						const remaining = deadline - performance.now();
						xo.state.fgFilterSeconds = Math.max(0, Math.ceil(remaining / 1000));
						if (remaining > 0) timer = setTimeout(tick, Math.min(1000, remaining));
					}
					tick();
				}

				fg.applyTicketFilterDraft = (force = false) => {
					if (!isCurrent() || !aside.isConnected) return;
					stopTimer();
					committedFilters = readFilterDraft();
					xo.state.fgFiltersPending = false;
					autofactura.captureTicketFilters(aside, 'fg');
					applyFilters();
					const { index } = pageMetadata(ticketsStore.document);
					const changed = !sameFilters(queryFilters(), appliedFilters(ticketsStore.document.documentElement));
					searchTickets(changed || force ? 1 : index, force);
				};

				fg.filterCountdownChanged = seconds => {
					if (!isCurrent() || !aside.isConnected) return;
					const showBadge = !hovering && seconds > 0;
					badge.hidden = !showBadge;
					badge.textContent = showBadge ? String(seconds) : '';
					if (!hovering && seconds === 0 && xo.state.fgFiltersPending) button.click();
				};

				fg.pressTicketFilterButton = () => {
					if (!isCurrent() || !aside.isConnected) return;
					if (button.classList.contains('ticket-filter-pressed')) {
						button.classList.remove('ticket-filter-pressed');
						void button.offsetWidth;
					}
					button.classList.add('ticket-filter-pressed');
					fg.applyTicketFilterDraft();
				};
				button.addEventListener('animationend', event => {
					if (event.target === button) button.classList.remove('ticket-filter-pressed');
				}, { signal });

				if (!fg.filterEventsRegistered) {
					xo.listener.on('change::#state:fgFilterSeconds', function ({ value }) {
						fg.filterCountdownChanged?.(value);
					});
					xo.listener.on('click::#fg-btn-apply', function () {
						fg.pressTicketFilterButton?.();
					});
					fg.filterEventsRegistered = true;
				}

				const stageFilter = event => {
					const control = event.target;
					if (!control.matches('#fg-filter-panel input, #fg-filter-panel select')) return;
					if (event.type === 'change') {
						if (control.id === 'fg-f-cliente') populateBranchFilter('');
						if (control.id === 'fg-f-cliente' || control.id === 'fg-f-sucursal') populateRecipientFilter();
						if (control.id === 'fg-f-receptor' && control.value && $('fg-f-estado').value === 'No facturado') {
							$('fg-f-estado').value = 'Facturado';
						}
						if (control.id === 'fg-f-estado' && control.value === 'No facturado') $('fg-f-receptor').value = '';
					}
					updateFilterIndicators();
					const draft = readFilterDraft();
					xo.state.fgFiltersPending = Object.keys(draft).some(name => draft[name] !== committedFilters[name]);
					stopTimer();
					if (xo.state.fgFiltersPending && !hovering) {
						const idle = 200 - (performance.now() - lastPointerMove);
						if (idle > 0) timer = setTimeout(startCountdown, idle);
						else startCountdown();
					}
				};
				aside.addEventListener('input', stageFilter, { signal });
				aside.addEventListener('change', stageFilter, { signal });
				aside.addEventListener('keydown', event => {
					if (event.key !== 'Enter' || event.isComposing || event.defaultPrevented ||
						!event.target.matches('#fg-filter-panel input:is([type="search"], [type="number"])')) return;
					event.preventDefault();
					if (!event.repeat) button.click();
				}, { signal });
				button.addEventListener('pointerenter', event => {
					if (event.pointerType !== 'mouse') return;
					hovering = true;
					stopTimer();
				}, { signal });
				button.addEventListener('pointerleave', event => {
					if (event.pointerType !== 'mouse') return;
					hovering = false;
					startCountdown();
				}, { signal });
				document.addEventListener('pointermove', event => {
					if (event.pointerType !== 'mouse' || !isCurrent() || !aside.isConnected) return;
					lastPointerMove = performance.now();
					if (!xo.state.fgFiltersPending) return;
					stopTimer();
					if (!hovering) timer = setTimeout(startCountdown, 200);
				}, { signal, passive: true });
				$('fg-btn-reset').addEventListener('click', () => {
					resetFilterValues();
					fg.applyTicketFilterDraft(true);
				}, { signal });
				signal.addEventListener('abort', stopTimer, { once: true });
			}

			async function openTicket(trigger) {
				if (!isCurrent() || !trigger.dataset.id) return;
				const model = ticketsStore.document;
				const source = Array.from(model.querySelectorAll('model > row')).find(row =>
					row.getAttribute('id')?.toLowerCase() === trigger.dataset.id.toLowerCase()
				);
				if (!source) {
					xo.dom.alert('El ticket ya no está disponible en esta página. Actualiza la consulta.');
					return;
				}
				const [ticket] = readTickets(model, [source]);
				const detail = model.createElementNS(viewNamespace, 'state:ticket-detail');
				const addAttributes = (node, attributes) => {
					for (const [key, value] of Object.entries(attributes)) node.setAttribute(key, value ?? '');
				};
				const amounts = ({ subtotal, iva, ieps, total }) => ({
					subtotal: money(subtotal), iva: money(iva), ieps: money(ieps), total: money(total)
				});
				const append = (name, attributes) => {
					const element = model.createElement(name);
					addAttributes(element, attributes);
					detail.appendChild(element);
				};
				addAttributes(detail, {
					fecha: ticket.fechaHora?.replace('T', ' ').slice(0, 19) || ticket.fecha,
					sucursal: ticket.sucursal, estado: ticket.estado,
					receptor: ticket.receptor.toLowerCase() === 'facturado' ? '' : ticket.receptor,
					...amounts(ticket)
				});
				for (const item of ticket.items) append('item', {
					codigo: item.codigo, descripcion: item.descripcion, cantidad: item.cantidad, unidad: item.unidad,
					...amounts({ subtotal: item.importe, iva: item.iva, ieps: item.ieps, total: item.importe + item.iva + item.ieps })
				});
				for (const payment of ticket.pagos) append('payment', { forma: payment.formaPago, monto: money(payment.monto) });
				if (!ticket.pagos.length && ticket.formaPago) append('payment', { forma: ticket.formaPago });
				const previous = model.documentElement.getElementsByTagNameNS(viewNamespace, 'ticket-detail')[0];
				if (previous) previous.replaceWith(detail);
				else model.documentElement.appendChild(detail);

				let dialog;
				try {
					const template = $('fg-ticket-dialog-template');
					dialog = template.content.firstElementChild.cloneNode(true);
					dialog.querySelector('#fg-ticket-dialog-title').textContent = 'Ticket ' + ticket.folio;
					dialog.addEventListener('close', (event) => {
						if (event.target !== dialog || dialog.open) return;
						detail.remove();
						dialog.remove();
					});
					document.body.appendChild(dialog);
					dialog.showModal();
					const content = dialog.querySelector('#fg-ticket-full');
					const status = document.createElement('p');
					status.className = 'p-3 mb-0';
					status.setAttribute('role', 'status');
					status.textContent = 'Cargando ticket…';
					content.replaceChildren(status);
					await content.render();
				} catch (error) {
				detail.remove();
					dialog?.remove();
					if (isCurrent()) xo.dom.alert('No se pudo mostrar el ticket.');
					console.error('Factura Global:', error);
				}
			}

			fg.openTicket = openTicket;
			if (!fg.openTicketListenerBound) {
				xo.listener.on('click::#fg-tbody .fg-view-ticket', function () {
					return fg.openTicket(this);
				});
				fg.openTicketListenerBound = true;
			}

			function bindStableFooterEvents() {
				if (!autofactura.fgConfirmModeListenerBound) {
					document.addEventListener('input', (event) => {
						if (event.target.matches?.('#fg-cfdi-rfc')) autofactura.fg.updateConfirmationMode?.();
					});
					autofactura.fgConfirmModeListenerBound = true;
				}
				document.addEventListener('click', (event) => {
					const statusButton = event.target.closest?.('#factura-global #fg-tbody .fg-status');
					if (statusButton) {
						if (clientInvoice) return;
						event.preventDefault();
						const ticket = allTickets.find(item => item.id == statusButton.dataset.id);
						const modal = document.querySelector('#fg-confirm');
						if (!ticket || !modal) return;
						fg.pendingStatusTicketId = ticket.id;
						fg.pendingStatusAction = statusButton.dataset.action || 'mark';
						const rfc = $('fg-cfdi-rfc');
						// El marcado manual no debe asumir Público en general: si se deja
						// vacío o se escribe "Facturado", se guarda el estado sin token.
						if (rfc) rfc.value = ticket.receptor || '';
						setText('fg-m-count', 1);
						setText('fg-m-total', money(ticket.total));
						autofactura.fg.updateConfirmationMode();
						if (modal.parentElement !== document.body) document.body.appendChild(modal);
						bootstrap.Modal.getOrCreateInstance(modal).show();
						return;
					}
					const button = event.target.closest?.(
						'#fg-btn-select-visible, #fg-btn-select-all, #fg-btn-unselect-visible, #fg-btn-unselect-all, #fg-btn-clear, #fg-btn-invoice, #fg-btn-prefactura'
					);
					if (!button) return;
					event.preventDefault();

					switch (button.id) {
						case 'fg-btn-prefactura':
							autofactura.prefactura.open(autofactura.fg.getInvoiceContext());
							break;
						case 'fg-btn-select-visible':
						selected.setMany(pageItems().filter(row => row.estado === 'No facturado').map(row => row.id), true);
							render();
							break;
						case 'fg-btn-select-all':
							selected.setMany(filtered.filter(row => row.estado === 'No facturado').map(row => row.id), true);
							render();
							break;
						case 'fg-btn-unselect-visible':
							selected.setMany(pageItems().map(row => row.id), false);
							render();
							break;
						case 'fg-btn-unselect-all':
							selected.setMany(filtered.map(row => row.id), false);
							render();
							break;
						case 'fg-btn-clear':
							autofactura.fg.clearSelection();
							break;
						case 'fg-btn-invoice': {
							const modal = document.querySelector('#fg-confirm');
							if (!modal || selected.size === 0 || (clientInvoice && selected.size !== 1)) return;
							fg.pendingStatusTicketId = null;
							fg.pendingStatusAction = null;
							autofactura.fg.updateConfirmationMode();
							if (modal.parentElement !== document.body) document.body.appendChild(modal);
							bootstrap.Modal.getOrCreateInstance(modal).show();
							break;
						}
					}
				}, { signal });
			}

			function bind(filterAside) {
				bindStableSelectionEvents();
				bindStablePaginationEvents();
				bindFilterEvents(filterAside);
				bindStableFooterEvents();
				root.addEventListener('change', event => {
					const input = event.target;
					if (!input.matches('.ticket-payment-radio > input')) return;
					const id = input.closest('tr[data-ticket-id]').dataset.ticketId;
					const row = Array.from(ticketsStore.document.select('model/row')).find(row => row.getAttribute('id') === id);
					if (!row) return;
					row.setAttribute('fp', input.value);
					$('fg-ticket-table').render().catch(error => console.error('Factura Global:', error));
				}, { signal });
			}

			function updateStickyHeaderOffset() {
				const toolbar = document.querySelector('#factura-global .toolbar');
				document.querySelector('#factura-global')?.style.setProperty('--fg-toolbar-h', toolbar.offsetHeight + 'px');
			}

			function moveConfirmModalToBody() {
				const modal = document.querySelector('#fg-confirm');
				if (modal && modal.parentElement !== document.body) {
					const previous = document.body.querySelector(':scope > #fg-confirm');
					if (previous) {
						bootstrap.Modal.getInstance(previous)?.dispose();
						previous.remove();
					}
					document.body.appendChild(modal);
				}
			}

			Object.assign(fg, {
				refreshSelection: () => {
					if (!isCurrent()) return;
					const selectedIds = new Set(selected);
					for (const input of document.querySelectorAll('#factura-global .fg-row')) input.checked = selectedIds.has(input.dataset.id);
					const selectAll = $('fg-chk-all');
					const rows = pageItems().filter(row => row.estado === 'No facturado');
					if (selectAll) {
						selectAll.disabled = rows.length === 0;
						selectAll.checked = rows.length > 0 && rows.every(row => selected.has(row.id));
					}
					updateSummary(); updateButtons();
				},
				showLoader,
				applyFilters,
				buildInvoiceXml,
				clearSelection: () => {
					fg.selected.clear();
					render();
				},
				getInvoiceContext: () => ({
					selectedIds: [...selected],
					selectedTickets: [...selected]
						.map(id => allTickets.find(ticket => ticket.id == id))
						.filter(Boolean),
					filteredTickets: filtered,
					allTickets,
					totals: selectedTotals(),
					receptor: document.getElementById('fg-cfdi-rfc')?.value?.trim() || '',
					cfdi: Object.fromEntries(['uso', 'metodo', 'forma'].map(key => [key, document.getElementById('fg-cfdi-' + key)?.selectedOptions[0]?.textContent?.trim() || '']))
				})
			});
			if (!fg.clearSelectionListenerBound) {
				xo.listener.on(`click::#fg-btn-clear`, () => fg.clearSelection());
				fg.clearSelectionListenerBound = true;
			}

			// bootstrap del módulo
			(async function init() {
				showLoader(true);
				const filterAside = await fgFiltersReady;
				if (!isCurrent() || !filterAside?.isConnected) return;
				moveConfirmModalToBody();
				attachShellFooter();
				attachHeaderPagination();
				function syncTickets(model) {
					model.documentElement.setAttributeNS(viewNamespace, 'state:modo', clientInvoice ? 'cliente' : 'global');
					if (clientInvoice && selected.size > 1) selected.clear();
					const tickets = readTickets(model);
					allTickets.splice(0, allTickets.length, ...tickets);
					populatePaymentFilter();
					const aside = $('fg-sidebar');
					const [desde, hasta, , tenant, branch, receptor] = appliedFilters(model.documentElement);
					$('fg-f-start').value = desde;
					$('fg-f-end').value = hasta;
					$('fg-f-cliente').value = authorizedClients.some(node => node.getAttribute('id') === tenant) ? tenant : '';
					populateBranchFilter(branch);
					autofactura.restoreTicketFilters(aside, 'fg');
					populateRecipientFilter(receptor);
					if ($('fg-f-receptor').value && $('fg-f-estado').value === 'No facturado') $('fg-f-estado').value = 'Facturado';
					committedFilters = readFilterDraft();
					xo.state.fgFiltersPending = false;
					xo.state.fgFilterSeconds = null;
					applyFilters();
					if (!sameFilters(queryFilters(), appliedFilters(model.documentElement))) searchTickets();
				}

				await ticketsStore.ready;
				if (ticketsStore.document.documentElement?.localName !== 'model') {
					await ticketsStore.fetch();
				}
				if (!isCurrent() || !filterAside.isConnected) return;
				await loadFilterCatalog();
				if (!isCurrent() || !filterAside.isConnected) return;
				syncTickets(ticketsStore.document);
				bind(filterAside);
				window.addEventListener('success', ({ detail }) => {
					if (detail?.request?.target !== ticketsStore.document || !isCurrent() || !filterAside.isConnected) return;
					syncTickets(ticketsStore.document);
				}, { signal });
				const toolbar = document.querySelector('#factura-global .toolbar');
				if (window.ResizeObserver && toolbar) {
					const observer = new ResizeObserver(updateStickyHeaderOffset);
					observer.observe(toolbar);
					signal.addEventListener('abort', () => observer.disconnect(), { once: true });
				}
				window.addEventListener('resize', updateStickyHeaderOffset, { signal });
				updateStickyHeaderOffset();
				showLoader(false);
			})().catch(error => {
				if (!isCurrent()) return;
				const status = $('fg-ticket-table')?.querySelector('[role="status"]');
				if (status) status.textContent = 'No se pudieron cargar los tickets.';
				showLoader(false);
				console.error('Factura Global:', error?.message || error?.status || error);
			});
		})();
	]]></script>

	<div class="modal fade" id="fg-confirm" tabindex="-1" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">Confirmar factura global</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"/>
				</div>
				<div class="modal-body">
					<div class="card">
						<div class="card-body">
							<p class="mb-1">Se facturarán <strong id="fg-m-count">0</strong> tickets por <strong id="fg-m-total">$0.00</strong>.</p>
							<h2 class="h6 mb-3">Parámetros de la factura</h2>
							<dl id="fg-m-current-receptor" class="mb-3" hidden="hidden">
								<dt>Receptor registrado</dt>
								<dd class="mb-0 text-break"></dd>
							</dl>
							<div class="row g-3">
								<div class="col-12">
									<label class="form-label" for="fg-cfdi-rfc">RFC del receptor</label>
									<input id="fg-cfdi-rfc" class="form-control">
									<xsl:if test="not($cliente)"><xsl:attribute name="value">XAXX010101000</xsl:attribute></xsl:if>
								</input>
									<div class="form-text"><xsl:choose><xsl:when test="$cliente">Captura el RFC del cliente para generar el token de Contpaqi.</xsl:when><xsl:otherwise>RFC con formato válido genera token. Otro texto solo guarda el estado.</xsl:otherwise></xsl:choose></div>
								</div>
								<!--<div class="col-12">
									<label class="form-label">Uso CFDI</label>
									<select id="fg-cfdi-uso" class="form-select">
										<option value="S01" selected>S01 - Sin efectos fiscales</option>
										<option value="G01">G01 - Adquisición de mercancías</option>
										<option value="G03">G03 - Gastos en general</option>
									</select>
								</div>
								<div class="col-6">
									<label class="form-label">Método de pago</label>
									<select id="fg-cfdi-metodo" class="form-select">
										<option value="PUE" selected>PUE - Pago en una sola exhibición</option>
										<option value="PPD">PPD - Pago en parcialidades o diferido</option>
									</select>
								</div>
								<div class="col-6">
									<label class="form-label">Forma de pago</label>
									<select id="fg-cfdi-forma" class="form-select">
										<option value="01">01 - Efectivo</option>
										<option value="03">03 - Transferencia</option>
										<option value="04">04 - Tarjeta de crédito</option>
										<option value="28" selected>28 - Tarjeta de débito</option>
									</select>
								</div>-->
							</div>
							<div class="form-text mt-2">* Ajusta según tu timbrado y reglas internas.</div>
						</div>
					</div>
					<!--<p class="text-muted small mb-0">¿Deseas continuar?</p>-->
				</div>
				<div class="modal-footer">
					<button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
					<button id="fg-m-confirm" class="btn btn-primary">Sí, facturar</button>
				</div>
			</div>
		</div>
	</div>
</section>

</section>
</xsl:template>
</xsl:stylesheet>
