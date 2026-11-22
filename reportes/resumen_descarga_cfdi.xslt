<!DOCTYPE stylesheet [
	<!ENTITY body "background-color:#FFFFFF; padding:5px; font-size:10px; font-family:Verdana, Arial, sans-serif; color:#263238;">
	<!ENTITY header "background-color:#ECEDEC; padding:6px; text-align:center; border:1px solid #364C4A; font-family:Verdana, Arial, sans-serif;">
	<!ENTITY celda "padding:6px; border-top:1px solid #E0E1DD; border-bottom:1px solid #ADAFAF; border-left:1px solid #E0E1DD; border-right:0px solid #E0E1DD; font-family:Verdana, Arial, sans-serif;">
	<!ENTITY celda_complemento "padding:6px; border-top:1px solid #E0E1DD; border-bottom:0; border-left:1px solid #E0E1DD; border-right:0px solid #E0E1DD; font-family:Verdana, Arial, sans-serif;">
	<!ENTITY celdaRight "padding:6px; border-top:1px solid #E0E1DD; border-bottom:1px solid #ADAFAF; border-left:1px solid #E0E1DD; border-right:1px solid #E0E1DD; font-family:Verdana, Arial, sans-serif;">
	<!ENTITY card "border:1px solid #D7DAD7; border-radius:6px; padding:10px; margin:6px 0; background-color:#FAFAFA;">
	<!ENTITY ok "background-color:#7EA84A; color:#FFFFFF;">
	<!ENTITY error "background-color:#B00B11; color:#FFFFFF;">
	<!ENTITY warning "background-color:#FFCC00; color:#FFFFFF;">
	<!ENTITY neutral "background-color:#747678; color:#FFFFFF;">
	<!ENTITY title "background-color:#364C4A; color:#FFFFFF; font-size:18px; padding:12px; text-align:center; font-family:Verdana, Arial, sans-serif;">
	<!ENTITY nowrap "white-space:nowrap;">
]>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xo="http://panax.io/xover"
	xmlns:state="http://panax.io/state"
	xmlns:filter="http://panax.io/state/filter"
	exclude-result-prefixes="xo state filter"
>

	<xsl:import href="../common.xslt"/>
	<xsl:strip-space elements="*"/>
	<xsl:output method="xml" omit-xml-declaration="yes" standalone="yes" indent="yes"/>
	<xsl:decimal-format name="money" grouping-separator="," decimal-separator="."/>

	<xsl:key name="solicitudesPorRFC" match="Solicitud" use="@RFC"/>

	<xsl:template match="DescargaMasiva">
		<body style="&body;" is="excel-selection">
			<h1 style="&title;">Resumen de Descarga Masiva SAT CFDI:</h1>
			<table excel-exportable="false" cellpadding="0" cellspacing="2" style="width:100%; color:#000000; font-size:10px; font-family:Verdana, Arial, sans-serif;">
				<tr>
					<td style="width:180px;">Fecha del reporte:</td>
					<th style="&header; text-align:left;">
						<xsl:value-of select="@FechaReporte"/>
					</th>
				</tr>
				<xsl:if test="@FechaDesde and @FechaHasta">
					<tr>
						<td>Ventana consultada:</td>
						<th style="&header; text-align:left;">
							<xsl:value-of select="@FechaDesde"/>
							<xsl:text> a </xsl:text>
							<xsl:value-of select="@FechaHasta"/>
						</th>
					</tr>
					<tr>
						<td>Horario de reintentos:</td>
						<th style="&header; text-align:left;">
							<xsl:value-of select="@HoraInicio"/>
							<xsl:text> a </xsl:text>
							<xsl:value-of select="@HoraFin"/>
							<xsl:text> hrs</xsl:text>
						</th>
					</tr>
				</xsl:if>
			</table>
			<xsl:call-template name="resumenEjecutivo"/>
			<xsl:call-template name="resumenRFC"/>
			<xsl:call-template name="estadoSolicitudes"/>
			<xsl:if test="Solicitud">
				<xsl:call-template name="incidenciasComplementos"/>
				<xsl:call-template name="detalleSolicitudes"/>
			</xsl:if>
			<xsl:if test="not(..)">
				<hr/>
				<div style="padding:10px; margin:10px; font-size:10px; color:#747678; font-family:Verdana, Arial, sans-serif;">
					AVISO DE CONFIDENCIALIDAD: Este correo electrónico es confidencial y para uso exclusivo de la(s) persona(s) a quien(es) se dirige. Si el lector de esta transmisión electrónica no es el destinatario, se le notifica que cualquier distribución o copia de la misma está estrictamente prohibida. Si ha recibido este correo por error le solicitamos notificar inmediatamente a la persona que lo envió y borrarlo definitivamente de su sistema.
				</div>
			</xsl:if>
		</body>
	</xsl:template>

	<xsl:template name="resumenEjecutivo">
		<style>
			<![CDATA[
.cfdi-summary-heading { display: flex; align-items: center; gap: .5rem; }
.cfdi-summary-toggle { display: inline-flex; align-items: center; padding: .2rem; border-radius: .25rem; cursor: pointer; }
.cfdi-summary-toggle:hover { background: #ecedec; }
#cfdi-hide-empty:focus-visible + .cfdi-summary-toggle { outline: 2px solid currentColor; outline-offset: 2px; }
#cfdi-hide-empty:not(:checked) + .cfdi-summary-toggle .cfdi-icon-hidden,
#cfdi-hide-empty:checked + .cfdi-summary-toggle .cfdi-icon-visible,
.cfdi-summary-heading:has(#cfdi-hide-empty:checked) + #cfdi-executive-summary tr[data-cfdi-empty] { display: none; }
			]]>
		</style>
		<h2 class="cfdi-summary-heading" style="font-size:15px; color:#364C4A; margin-top:18px;">
			<xsl:text>Resumen ejecutivo</xsl:text>
			<input type="checkbox" id="cfdi-hide-empty" class="visually-hidden" aria-label="Ocultar filas sin datos" aria-controls="cfdi-executive-summary"/>
			<label for="cfdi-hide-empty" class="cfdi-summary-toggle" title="Mostrar u ocultar filas sin datos">
				<svg xmlns="http://www.w3.org/2000/svg" class="cfdi-icon-visible" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round" aria-hidden="true">
					<path d="M2 12s4-6 10-6 10 6 10 6-4 6-10 6-10-6-10-6Z"/><circle cx="12" cy="12" r="3"/>
				</svg>
				<svg xmlns="http://www.w3.org/2000/svg" class="cfdi-icon-hidden" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
					<path d="M9.9 6.2C17 4.7 22 12 22 12a18.5 18.5 0 0 1-3 3.3M6.3 7.1A19.1 19.1 0 0 0 2 12s4 6 10 6c1.6 0 3.1-.4 4.4-1M3 3l18 18"/>
				</svg>
			</label>
		</h2>
		<table id="cfdi-executive-summary" is="value-filter" cellpadding="0" cellspacing="2" style="width:100%; font-size:10px; font-family:Verdana, Arial, sans-serif;">
			<tr>
				<th style="&header;">Concepto</th>
				<th style="&header; width:110px;">Cantidad</th>
				<th style="&header;">Comentario</th>
			</tr>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Solicitudes SAT'"/>
				<xsl:with-param name="nodes" select="Solicitud"/>
				<xsl:with-param name="filterPath">Solicitud</xsl:with-param>
				<xsl:with-param name="comment" select="'Consultas registradas en la ventana del reporte'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Solicitudes descargadas/terminadas'"/>
				<xsl:with-param name="nodes" select="Solicitud[@EstatusConsulta='Descargado' or @EstatusConsulta='Terminada' or @EstatusConsulta='Terminado' or @EstatusConsulta='Importado']"/>
				<xsl:with-param name="comment" select="'Con resultado final o paquetes descargados'"/>
				<xsl:with-param name="filterName" select="'EstatusConsulta'"/>
				<xsl:with-param name="filterNode" select="'Solicitud'"/>
				<xsl:with-param name="filterPath">Solicitud[@EstatusConsulta='Descargado' or @EstatusConsulta='Terminada' or @EstatusConsulta='Terminado' or @EstatusConsulta='Importado']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'Descargado|Terminada|Terminado|Importado'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Solicitudes en proceso'"/>
				<xsl:with-param name="nodes" select="Solicitud[not(@EstatusConsulta='Descargado' or @EstatusConsulta='Terminada' or @EstatusConsulta='Terminado' or @EstatusConsulta='Importado' or @EstatusConsulta='Error' or @EstatusConsulta='SinInformacion' or @EstatusConsulta='Revision')]"/>
				<xsl:with-param name="comment" select="'Pueden continuar en reintento dentro de la ventana operativa'"/>
				<xsl:with-param name="filterName" select="'EstatusConsulta'"/>
				<xsl:with-param name="filterNode" select="'Solicitud'"/>
				<xsl:with-param name="filterPath">Solicitud[not(@EstatusConsulta='Descargado' or @EstatusConsulta='Terminada' or @EstatusConsulta='Terminado' or @EstatusConsulta='Importado' or @EstatusConsulta='Error' or @EstatusConsulta='SinInformacion' or @EstatusConsulta='Revision')]</xsl:with-param>
				<xsl:with-param name="filterValue" select="'*'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Solicitudes con error'"/>
				<xsl:with-param name="nodes" select="Solicitud[@EstatusConsulta='Error' or @EstatusConsulta='Revision']"/>
				<xsl:with-param name="comment" select="'Requieren revisión o nuevo intento'"/>
				<xsl:with-param name="filterName" select="'EstatusConsulta'"/>
				<xsl:with-param name="filterNode" select="'Solicitud'"/>
				<xsl:with-param name="filterPath">Solicitud[@EstatusConsulta='Error' or @EstatusConsulta='Revision']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'Error|Revision'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Solicitudes sin información'"/>
				<xsl:with-param name="nodes" select="Solicitud[@EstatusConsulta='SinInformacion']"/>
				<xsl:with-param name="comment" select="'El SAT no encontró comprobantes para el periodo consultado'"/>
				<xsl:with-param name="filterName" select="'EstatusConsulta'"/>
				<xsl:with-param name="filterNode" select="'Solicitud'"/>
				<xsl:with-param name="filterPath">Solicitud[@EstatusConsulta='SinInformacion']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'SinInformacion'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'CFDI descargados'"/>
				<xsl:with-param name="nodes" select="//Comprobante"/>
				<xsl:with-param name="comment" select="'Comprobantes registrados en el detalle'"/>
				<xsl:with-param name="filterName" select="'Comprobante'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante</xsl:with-param>
				<xsl:with-param name="filterValue" select="'*'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Facturas'"/>
				<xsl:with-param name="nodes" select="//Comprobante[@Tipo='factura']"/>
				<xsl:with-param name="comment" select="'CFDI de ingreso/egreso clasificados como factura'"/>
				<xsl:with-param name="filterName" select="'Tipo'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante[@Tipo='factura']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'factura'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Complementos'"/>
				<xsl:with-param name="nodes" select="//Comprobante[@Tipo='complemento']"/>
				<xsl:with-param name="comment" select="'Complementos de pago descargados'"/>
				<xsl:with-param name="filterName" select="'Tipo'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante[@Tipo='complemento']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'complemento'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Notas de crédito'"/>
				<xsl:with-param name="nodes" select="//Comprobante[@Tipo='nota_credito']"/>
				<xsl:with-param name="comment" select="'CFDI clasificados como nota de crédito'"/>
				<xsl:with-param name="filterName" select="'Tipo'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante[@Tipo='nota_credito']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'nota_credito'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Complementos con incidencias'"/>
				<xsl:with-param name="nodes" select="//Comprobante[@Tipo='complemento'][not(FacturaRelacionada) or FacturaRelacionada[@Estatus!='Aplicado']]"/>
				<xsl:with-param name="comment" select="'Complementos con facturas relacionadas no aplicadas, canceladas o no localizadas'"/>
				<xsl:with-param name="filterName" select="'ComplementosConIncidencias'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante[@Tipo='complemento'][not(FacturaRelacionada) or FacturaRelacionada[@Estatus!='Aplicado']]</xsl:with-param>
				<xsl:with-param name="filterValue" select="'*'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Facturas relacionadas no encontradas'"/>
				<xsl:with-param name="nodes" select="//Comprobante[@Tipo='complemento']/FacturaRelacionada[@Estatus='No encontrado']"/>
				<xsl:with-param name="comment" select="'Relaciones que no existen en Compras.Facturas'"/>
				<xsl:with-param name="filterName" select="'FacturasRelacionadasNoEncontradas'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante[@Tipo='complemento']/FacturaRelacionada[@Estatus='No encontrado']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'*'"/>
			</xsl:call-template>
			<xsl:call-template name="summaryRow">
				<xsl:with-param name="label" select="'Facturas relacionadas canceladas'"/>
				<xsl:with-param name="nodes" select="//Comprobante[@Tipo='complemento']/FacturaRelacionada[@Estatus='Cancelado']"/>
				<xsl:with-param name="comment" select="'Relaciones cuyo StatusSAT indica cancelación'"/>
				<xsl:with-param name="filterName" select="'FacturasRelacionadasCanceladas'"/>
				<xsl:with-param name="filterNode" select="'Comprobante'"/>
				<xsl:with-param name="filterPath">//Comprobante[@Tipo='complemento']/FacturaRelacionada[@Estatus='Cancelado']</xsl:with-param>
				<xsl:with-param name="filterValue" select="'*'"/>
			</xsl:call-template>
		</table>
	</xsl:template>

	<xsl:template name="summaryRow">
		<xsl:param name="label"/>
		<xsl:param name="value"/>
		<xsl:param name="nodes"/>
		<xsl:param name="comment"/>
		<xsl:param name="filterName"/>
		<xsl:param name="filterNode"/>
		<xsl:param name="filterPath"/>
		<xsl:param name="filterValue"/>
		<tr>
			<xsl:if test="($filterPath != '' and not($nodes)) or ($filterPath = '' and (normalize-space($value) = '' or number($value) = 0))">
				<xsl:attribute name="data-cfdi-empty">true</xsl:attribute>
			</xsl:if>
			<td style="&celda;">
				<xsl:value-of select="$label"/>
			</td>
			<td style="&celda; text-align:right; font-weight:bold;">
				<xsl:attribute name="class">
					<xsl:text>filterable</xsl:text>
					<xsl:if test="$filterPath != '' and @filter:scope = concat('set:', $filterPath)">
						<xsl:text> value-filter-active</xsl:text>
					</xsl:if>
				</xsl:attribute>
				<xsl:if test="$filterName != ''">
					<xsl:attribute name="filter-target">//DescargaMasiva</xsl:attribute>
					<xsl:attribute name="filter-name">
						<xsl:value-of select="$filterName"/>
					</xsl:attribute>
					<xsl:attribute name="filter-node">
						<xsl:value-of select="$filterNode"/>
					</xsl:attribute>
					<xsl:attribute name="filter-path">
						<xsl:value-of select="$filterPath"/>
					</xsl:attribute>
					<xsl:attribute name="filter-value">
						<xsl:value-of select="$filterValue"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$filterPath != ''">
						<xsl:attribute name="xo-scope">set:<xsl:value-of select="$filterPath"/></xsl:attribute>
						<xsl:value-of select="count($nodes)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style="&celdaRight; color:#747678;">
				<xsl:value-of select="$comment"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="estadoSolicitudes">
		<h2 style="font-size:15px; color:#364C4A; margin-top:18px;">Estado de solicitudes</h2>
		<table cellpadding="0" cellspacing="2" style="width:100%; font-size:10px; font-family:Verdana, Arial, sans-serif;">
			<tr>
				<th style="&header;">RFC</th>
				<th style="&header;">Fecha consultada</th>
				<th style="&header;">Sentido</th>
				<th style="&header;">Id de Solicitud</th>
				<th style="&header;">Estatus SAT</th>
				<th style="&header;">CFDI SAT</th>
				<th style="&header;">Procesados</th>
				<th style="&header;">Última actualización</th>
			</tr>
			<xsl:variable name="activeFilter" select="@filter:scope"/>
			<xsl:for-each select="Solicitud[not($activeFilter) or @state:filtered or .//@state:filtered]">
				<xsl:sort select="@FechaConsultada" order="descending"/>
				<tr>
					<td style="&celda;">
						<xsl:value-of select="@RFC"/>
					</td>
					<td style="&celda; &nowrap;">
						<xsl:value-of select="@FechaConsultada"/>
					</td>
					<td style="&celda; &nowrap;">
						<xsl:value-of select="@Direccion"/>
					</td>
					<td style="&celda;">
						<xsl:apply-templates select="@SolicitudId"/>
					</td>
					<td style="&celda; &nowrap; text-align:center; font-weight:bold;">
						<xsl:attribute name="style">
							<xsl:text>&celda; &nowrap; text-align:center; font-weight:bold; </xsl:text>
							<xsl:call-template name="styleEstatusSolicitud">
								<xsl:with-param name="estatus" select="@EstatusConsulta"/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="@EstatusConsulta" mode="etiquetaEstatus"/>
					</td>
					<td style="&celda; text-align:right;">
						<xsl:value-of select="@Comprobantes"/>
					</td>
					<td style="&celda; text-align:right;">
						<xsl:value-of select="count(Comprobante)"/>
					</td>
					<td style="&celdaRight; &nowrap;">
						<xsl:value-of select="@UltimaActualizacion"/>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template name="incidenciasComplementos">
		<h2 style="font-size:15px; color:#364C4A; margin-top:18px;">Complementos con incidencias</h2>
		<xsl:choose>
			<xsl:when test="count(//Comprobante[@Tipo='complemento'][not(FacturaRelacionada) or FacturaRelacionada[@Estatus!='Aplicado']]) &gt; 0">
				<table cellpadding="0" cellspacing="2" style="width:100%; font-size:10px; font-family:Verdana, Arial, sans-serif;">
					<tr>
						<th style="&header;">RFC</th>
						<th style="&header;">UUID complemento</th>
						<th style="&header;">Emisor</th>
						<th style="&header;">Factura relacionada</th>
						<th style="&header;">Serie/Folio</th>
						<th style="&header;">Imp. pagado</th>
						<th style="&header;">Problema</th>
					</tr>
					<xsl:for-each select="//Comprobante[@Tipo='complemento'][not(FacturaRelacionada)]">
						<tr>
							<td style="&celda;">
								<xsl:value-of select="../@RFC"/>
							</td>
							<td style="&celda;">
								<xsl:apply-templates select="@uuid"/>
							</td>
							<td style="&celda;">
								<xsl:value-of select="@Emisor"/>
							</td>
							<td style="&celda;" colspan="3">Sin factura relacionada en el XML de reporte</td>
							<td style="&celdaRight; &warning; font-weight:bold;">Sin relación</td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="//Comprobante[@Tipo='complemento']/FacturaRelacionada[@Estatus!='Aplicado']">
						<tr>
							<td style="&celda;">
								<xsl:value-of select="../../@RFC"/>
							</td>
							<td style="&celda;">
								<xsl:apply-templates select="../@uuid"/>
							</td>
							<td style="&celda;">
								<xsl:value-of select="../@Emisor"/>
							</td>
							<td style="&celda;">
								<xsl:apply-templates select="@uuid"/>
							</td>
							<td style="&celda;">
								<xsl:value-of select="@Serie"/>
								<xsl:if test="@Serie and @Folio">
									<xsl:text> / </xsl:text>
								</xsl:if>
								<xsl:value-of select="@Folio"/>
							</td>
							<td style="&celda; text-align:right;">
								<xsl:call-template name="money">
									<xsl:with-param name="value" select="@ImpPagado"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:attribute name="style">
									<xsl:text>&celdaRight; font-weight:bold; text-align:center; </xsl:text>
									<xsl:call-template name="styleEstatusFactura">
										<xsl:with-param name="estatus" select="@Estatus"/>
									</xsl:call-template>
								</xsl:attribute>
								<xsl:value-of select="@Estatus"/>
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<div style="&card; border-left:5px solid #7EA84A;">
					No se detectaron incidencias en facturas relacionadas de complementos.
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="resumenRFC">
		<h2 style="font-size:15px; color:#364C4A; margin-top:18px;">Resumen por RFC</h2>
		<table cellpadding="0" cellspacing="2" style="width:100%; font-size:10px; font-family:Verdana, Arial, sans-serif;">
			<tr>
				<th style="&header;">RFC</th>
				<th style="&header;">Solicitudes</th>
				<th style="&header;">CFDI SAT</th>
				<th style="&header;">Procesados</th>
				<th style="&header;">Complementos</th>
				<th style="&header;">Incidencias</th>
			</tr>
			<xsl:for-each select="Solicitud[generate-id() = generate-id(key('solicitudesPorRFC', @RFC)[1])]">
				<xsl:sort select="@RFC"/>
				<xsl:variable name="rfc" select="@RFC"/>
				<tr>
					<td style="&celda;">
						<xsl:value-of select="$rfc"/>
					</td>
					<td style="&celda; text-align:right;">
						<xsl:value-of select="count(key('solicitudesPorRFC', $rfc))"/>
					</td>
					<td style="&celda; text-align:right;">
						<xsl:value-of select="sum(key('solicitudesPorRFC', $rfc)/@Comprobantes)"/>
					</td>
					<td style="&celda; text-align:right;">
						<xsl:value-of select="count(key('solicitudesPorRFC', $rfc)/Comprobante)"/>
					</td>
					<td style="&celda; text-align:right;">
						<xsl:value-of select="count(key('solicitudesPorRFC', $rfc)/Comprobante[@Tipo='complemento'])"/>
					</td>
					<td style="&celdaRight; text-align:right; font-weight:bold;">
						<xsl:value-of select="count(key('solicitudesPorRFC', $rfc)/Comprobante[@Tipo='complemento'][not(FacturaRelacionada) or FacturaRelacionada[@Estatus!='Aplicado']])"/>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template name="detalleSolicitudes">
		<h2 style="font-size:15px; color:#364C4A; margin-top:18px;">Detalle de solicitudes</h2>
		<xsl:if test="not(..)">
			<div style="font-size:10px; color:#747678; margin-bottom:8px;">
				En clientes de correo compatibles, cada solicitud puede contraerse o expandirse. En Outlook puede mostrarse siempre abierto o sin interacción.
			</div>
		</xsl:if>
		<xsl:variable name="activeFilter" select="@filter:scope"/>
		<xsl:for-each select="Solicitud[not($activeFilter) or @state:filtered or .//@state:filtered]">
			<xsl:sort select="@FechaConsultada" order="descending"/>
			<details id="{@SolicitudId}">
				<xsl:variable name="detalleComprobantes" select="Comprobante[not($activeFilter) or ../@state:filtered and not(contains($activeFilter, 'Comprobante') or contains($activeFilter, 'FacturaRelacionada')) or @state:filtered or FacturaRelacionada[@state:filtered]]"/>
				<xsl:variable name="incidencias" select="$detalleComprobantes[@Tipo='complemento'][not(FacturaRelacionada) or FacturaRelacionada[@Estatus!='Aplicado']]"/>
				<xsl:if test="@EstatusConsulta='Error' or $incidencias">
					<xsl:attribute name="open">open</xsl:attribute>
				</xsl:if>
				<xsl:variable name="bg-solicitud">
					<xsl:choose>
						<xsl:when test="$incidencias">#A92A2A</xsl:when>
						<xsl:when test="not($detalleComprobantes)">#6C757D</xsl:when>
						<xsl:otherwise>#3F5452</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<summary style="font-weight:bold; cursor:pointer; padding:8px; border:1px solid #D7DAD7; margin-top:8px; background:{$bg-solicitud}; color:white;">
					<xsl:value-of select="@RFC"/>
					<xsl:text> — </xsl:text>
					<xsl:value-of select="@FechaConsultada"/>
					<xsl:text> — </xsl:text>
					<xsl:apply-templates select="@EstatusConsulta" mode="etiquetaEstatus"/>
					<xsl:text> — CFDI SAT: </xsl:text>
					<xsl:value-of select="@Comprobantes"/>
					<xsl:text>, procesados: </xsl:text>
					<xsl:value-of select="count($detalleComprobantes)"/>
					<xsl:if test="$incidencias">
						<xsl:text> — Incidencias en complementos: </xsl:text>
						<xsl:value-of select="count($incidencias)"/>
					</xsl:if>
				</summary>
				<div style="&card; padding:6px 10px 7px 10px;">
					<table cellpadding="0" cellspacing="0" style="width:100%; font-size:9px; font-family:Verdana, Arial, sans-serif; color:#333;">
						<tr>
							<td style="width:34%; padding-right:10px; vertical-align:top;">
								<strong style="color:#555;">Solicitud</strong>
								<br/>
								<span style="color:#222;">
									<xsl:value-of select="@SolicitudId"/>
								</span>
							</td>

							<td style="width:33%; padding:0 10px; border-left:1px solid #D7DAD7; vertical-align:top;">
								<strong style="color:#555;">Última actualización</strong>
								<br/>
								<xsl:value-of select="@UltimaActualizacion"/>
							</td>

							<td style="width:33%; padding-left:10px; border-left:1px solid #D7DAD7; vertical-align:top;">
								<strong style="color:#555;">Dirección</strong>
								<br/>
								<xsl:value-of select="@Direccion"/>
							</td>
						</tr>
					</table>

					<xsl:if test="count($detalleComprobantes) &gt; 0">
						<table cellpadding="0" cellspacing="2" style="width:100%; font-size:10px; font-family:Verdana, Arial, sans-serif; margin-top: .5rem;">
							<tr>
								<th style="&header;">#</th>
								<th style="&header;">Fecha</th>
								<th style="&header;">Tipo</th>
								<th style="&header;">UUID</th>
								<th style="&header;">Emisor</th>
								<th style="&header;">Receptor</th>
								<th style="&header;">Total</th>
								<th style="&header;">StatusSAT</th>
								<th style="&header;">Estatus</th>
							</tr>
							<xsl:for-each select="$detalleComprobantes">
								<xsl:sort select="@Fecha"/>
								<xsl:variable name="estilo_celda">
									<xsl:choose>
										<xsl:when test="FacturaRelacionada">&celda_complemento;</xsl:when>
										<xsl:otherwise>&celda;</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<tr>
									<td style="{$estilo_celda} &nowrap; text-align: center;">
										<xsl:value-of select="position()"/>
									</td>
									<td style="{$estilo_celda} &nowrap;">
										<xsl:value-of select="@Fecha"/>
									</td>
									<td style="{$estilo_celda}">
										<xsl:value-of select="@Tipo"/>
									</td>
									<td style="{$estilo_celda}">
										<xsl:apply-templates select="@uuid"/>
									</td>
									<td style="{$estilo_celda}">
										<xsl:value-of select="@Emisor"/>
									</td>
									<td style="{$estilo_celda}">
										<xsl:value-of select="@Receptor"/>
									</td>
									<td style="{$estilo_celda} text-align:right;">
										<xsl:call-template name="money">
											<xsl:with-param name="value" select="@Total"/>
										</xsl:call-template>
									</td>
									<td style="{$estilo_celda}">
										<xsl:value-of select="@StatusSAT"/>
									</td>
									<td>
										<xsl:attribute name="style">
											<xsl:value-of select="$estilo_celda"/>
											<xsl:text> font-weight:bold; text-align:center; </xsl:text>
											<xsl:call-template name="styleEstatusFactura">
												<xsl:with-param name="estatus" select="@Estatus"/>
											</xsl:call-template>
										</xsl:attribute>
										<xsl:value-of select="@Estatus"/>
									</td>
								</tr>
								<xsl:if test="FacturaRelacionada[not($activeFilter) or ../../@state:filtered and not(contains($activeFilter, 'Comprobante') or contains($activeFilter, 'FacturaRelacionada')) or ../@state:filtered and not(contains($activeFilter, 'FacturaRelacionada')) or @state:filtered]">
									<tr>
										<td>&#160;</td>
										<td colspan="8" style="padding:0; border-top:none; background-color:#FAFAFA;">
											<table cellpadding="0" cellspacing="0" style="width:100%; font-size:10px; font-family:Verdana, Arial, sans-serif; border-collapse:collapse;">
												<!--<tr>
													<td style="padding:4px 8px 2px 18px; background:#FAFAFA; border-left:4px solid #D7DAD7; color:#666; font-size:9px; font-weight:bold; text-transform:uppercase;">
														Facturas relacionadas
													</td>
												</tr>-->
												<xsl:for-each select="FacturaRelacionada[not($activeFilter) or ../../@state:filtered and not(contains($activeFilter, 'Comprobante') or contains($activeFilter, 'FacturaRelacionada')) or ../@state:filtered and not(contains($activeFilter, 'FacturaRelacionada')) or @state:filtered]">
													<tr>
														<td>
															<xsl:attribute name="style">
																<xsl:text>padding:4px 8px 5px 18px; border-left:4px solid #D7DAD7; border-top:1px solid #E5E5E5; </xsl:text>
																<xsl:call-template name="styleEstatusFacturaRelacionada">
																	<xsl:with-param name="estatus" select="@Estatus"/>
																</xsl:call-template>
															</xsl:attribute>
															<strong>Factura:</strong>
															<span>
																<xsl:apply-templates select="@uuid"/>
															</span>
															<xsl:apply-templates mode="facturas_relacionadas" select="@SerieFolio|@FechaPago|@ImpPagado|@ImpSaldoInsoluto|@SaldoInsoluto|@Estatus"/>
														</td>
													</tr>
												</xsl:for-each>
											</table>
										</td>
									</tr>
								</xsl:if>
							</xsl:for-each>
						</table>
					</xsl:if>
				</div>
			</details>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="facturas_relacionadas" match="@SerieFolio">
		<xsl:text> | </xsl:text>
		<strong>Folio:</strong>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="string(.) != ''">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>-</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="facturas_relacionadas" match="@FechaPago">
		<xsl:text> | </xsl:text>
		<strong>Pago:</strong>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="string(.) != ''">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>-</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="facturas_relacionadas" match="@ImpPagado">
		<xsl:text> | </xsl:text>
		<strong>Imp. pagado:</strong>
		<xsl:text> </xsl:text>
		<xsl:call-template name="money">
			<xsl:with-param name="value" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="facturas_relacionadas" match="@ImpSaldoInsoluto|@SaldoInsoluto">
		<xsl:text> | </xsl:text>
		<strong>Saldo:</strong>
		<xsl:text> </xsl:text>
		<xsl:call-template name="money">
			<xsl:with-param name="value" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="facturas_relacionadas" match="@Estatus">
		<span style="float:right;">
			<xsl:text> | </xsl:text>
			<strong>Estatus:</strong>
			<xsl:text> </xsl:text>
			<span>
				<xsl:attribute name="style">
					<xsl:text>display:inline-block;
					padding:1px 8px;
					border-radius:10px;
					font-size:9px;
					font-weight:bold;
					background:white;
					border:1px solid;
					line-height:1.2;
				</xsl:text>

					<xsl:choose>
						<xsl:when test=".='Aplicado'">
							<xsl:text>border-color:#7BAA43;color:#5C8A2F;</xsl:text>
						</xsl:when>
						<xsl:when test=".='No encontrado'">
							<xsl:text>border-color:#C62828;color:#B71C1C;</xsl:text>
						</xsl:when>
						<xsl:when test=".='Cancelado'">
							<xsl:text>border-color:#F39C12;color:#B9770E;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>border-color:#7F8C8D;color:#555;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:value-of select="."/>
			</span>
		</span>
	</xsl:template>

	<xsl:template name="styleEstatusFacturaRelacionada">
		<xsl:param name="estatus"/>
		<xsl:choose>
			<xsl:when test="$estatus='Aplicado'">background-color:#F4FAEF; border-left-color:#7EA84A; color:#263238;</xsl:when>
			<xsl:when test="$estatus='Cancelado' or $estatus='No encontrado' or $estatus='Descargado sin aplicar'">background-color:#FDECEC; border-left-color:#B00B11; color:#7A1F1F;</xsl:when>
			<xsl:otherwise>background-color:#FFF8D8; border-left-color:#FFCC00; color:#263238;</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="money">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="string($value) != ''">
				<xsl:value-of select="format-number(number($value), '$#,##0.00', 'money')"/>
			</xsl:when>
			<xsl:otherwise>-</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@EstatusConsulta" mode="etiquetaEstatus">
		<xsl:choose>
			<xsl:when test=".='SinInformacion'">Sin información</xsl:when>
			<xsl:when test=".='EnProceso'">En proceso</xsl:when>
			<xsl:when test=".='Revision'">Revisión</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="styleEstatusSolicitud">
		<xsl:param name="estatus"/>
		<xsl:choose>
			<xsl:when test="$estatus='Descargado' or $estatus='Terminada' or $estatus='Terminado' or $estatus='Importado'">background-color:#7EA84A; color:#FFFFFF;</xsl:when>
			<xsl:when test="$estatus='Error' or $estatus='Revision'">background-color:#B00B11; color:#FFFFFF;</xsl:when>
			<xsl:otherwise>background-color:#FFCC00; color:#263238;</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="styleEstatusFactura">
		<xsl:param name="estatus"/>
		<xsl:choose>
			<xsl:when test="$estatus='Aplicado'">background-color:#7EA84A; color:#FFFFFF;</xsl:when>
			<xsl:when test="$estatus='Cancelado' or $estatus='No encontrado' or $estatus='Descargado sin aplicar'">background-color:#B00B11; color:#FFFFFF;</xsl:when>
			<xsl:otherwise>background-color:#FFCC00; color:#263238;</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@SolicitudId">
		<a href="#" data-solicitud-id="{.}" onclick="return mostrarDetalleSolicitud(this.dataset.solicitudId);">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>
	<xsl:template match="Comprobante/@uuid|FacturaRelacionada/@uuid">
		<xsl:choose>
			<xsl:when test="normalize-space(.)!=''">
				<span style="white-space:nowrap">
				<a href="#" data-cfdi-uuid="{.}" title="Ver comprobante">
				<xsl:value-of select="."/>
				</a>
				<button type="button" class="btn btn-sm p-0" data-cfdi-uuid="{.}" title="Ver CFDI" aria-label="Ver CFDI {.}" style="vertical-align:middle;margin-inline-start:.5rem">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-filetype-pdf" viewBox="0 0 16 16" aria-hidden="true">
			<path fill-rule="evenodd" d="M14 4.5V14a2 2 0 0 1-2 2h-1v-1h1a1 1 0 0 0 1-1V4.5h-2A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v9H2V2a2 2 0 0 1 2-2h5.5zM1.6 11.85H0v3.999h.791v-1.342h.803q.43 0 .732-.173.305-.175.463-.474a1.4 1.4 0 0 0 .161-.677q0-.375-.158-.677a1.2 1.2 0 0 0-.46-.477q-.3-.18-.732-.179m.545 1.333a.8.8 0 0 1-.085.38.57.57 0 0 1-.238.241.8.8 0 0 1-.375.082H.788V12.48h.66q.327 0 .512.181.185.183.185.522m1.217-1.333v3.999h1.46q.602 0 .998-.237a1.45 1.45 0 0 0 .595-.689q.196-.45.196-1.084 0-.63-.196-1.075a1.43 1.43 0 0 0-.589-.68q-.396-.234-1.005-.234zm.791.645h.563q.371 0 .609.152a.9.9 0 0 1 .354.454q.118.302.118.753a2.3 2.3 0 0 1-.068.592 1.1 1.1 0 0 1-.196.422.8.8 0 0 1-.334.252 1.3 1.3 0 0 1-.483.082h-.563zm3.743 1.763v1.591h-.79V11.85h2.548v.653H7.896v1.117h1.606v.638z"/>
		</svg>
				</button>
				</span>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
