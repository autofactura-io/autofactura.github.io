<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:state="http://panax.io/state"
    exclude-result-prefixes="state">
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    <xsl:key name="ticket" match="model/row" use="@id"/>

    <xsl:template match="/">
        <div id="fg-ticket-table">
            <table class="table table-hover align-middle mb-0" id="fg-tbl">
							<thead>
								<tr>
									<th class="sticky" style="width:42px;">
										<input id="fg-chk-all" class="form-check-input" type="checkbox" title="Seleccionar visibles"/>
									</th>
									<th class="sticky">Fecha</th>
									<th class="sticky">Folio</th>
									<th class="sticky">Sucursal</th>
									<th class="sticky">Forma de pago</th>
									<th class="sticky">Producto</th>
									<th class="sticky text-end">Subtotal</th>
									<th class="sticky text-end">IVA</th>
									<th class="sticky text-end">IEPS</th>
									<th class="sticky text-end">Total</th>
									<th class="sticky">Estado</th>
								</tr>
							</thead>
							<tbody id="fg-tbody">
            <xsl:choose>
                <xsl:when test="model/state:factura-global/ticket">
                    <xsl:apply-templates select="model/state:factura-global/ticket"/>
                </xsl:when>
                <xsl:otherwise>
                    <tr><td colspan="11" role="status">
                        <xsl:choose>
                            <xsl:when test="model/state:factura-global">No hay tickets para los filtros aplicados.</xsl:when>
                            <xsl:otherwise>Cargando tickets…</xsl:otherwise>
                        </xsl:choose>
                    </td></tr>
                </xsl:otherwise>
            </xsl:choose>
        </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="ticket">
        <xsl:variable name="source" select="key('ticket',@id)"/>
        <xsl:variable name="billed" select="boolean($source/@receptor[.!=''])"/>
        <xsl:variable name="payment" select="$source/@fp"/>
        <tr data-ticket-id="{@id}">
            <td>
                <input class="form-check-input fg-row" type="checkbox" data-id="{@id}">
                    <xsl:if test="$source/@state:selected='true' or $source/@state:selected='1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$billed">
                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                        <xsl:attribute name="title">El ticket ya está marcado como facturado</xsl:attribute>
                    </xsl:if>
                </input>
            </td>
            <td><xsl:value-of select="@fecha"/></td>
            <td class="cursor-pointer text-primary text-decoration-underline" data-id="{@id}" title="Ver detalle"><xsl:value-of select="$source/@tkt"/></td>
            <td><xsl:value-of select="$source/@suc"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="payment">
                        <div class="ticket-payment-list small" role="radiogroup" aria-label="Formas de pago">
                            <xsl:for-each select="payment">
                                <xsl:variable name="active" select="@forma=$payment"/>
                                <div class="ticket-payment-line d-flex justify-content-between gap-2">
                                    <xsl:if test="$active"><xsl:attribute name="class">ticket-payment-line d-flex justify-content-between gap-2 is-selected</xsl:attribute></xsl:if>
                                    <label class="ticket-payment-radio" role="radio" aria-checked="{$active}">
                                        <input type="radio" name="fg-payment-{../@id}" value="{@forma}">
                                            <xsl:if test="$active"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                        </input>
                                        <span class="ticket-payment-option"><xsl:value-of select="@forma"/></span>
                                        <span class="text-nowrap"><xsl:value-of select="@monto"/></span>
                                    </label>
                                </div>
                            </xsl:for-each>
                        </div>
                    </xsl:when>
                    <xsl:when test="$payment[.!='']"><span class="small text-muted"><xsl:value-of select="$payment"/></span></xsl:when>
                    <xsl:otherwise><span class="small text-muted">Sin forma de pago</span></xsl:otherwise>
                </xsl:choose>
            </td>
            <td class="ticket-detail-cell" colspan="5">
                <table class="ticket-detail-table" data-ticket-detail="{@id}">
                    <colgroup>
                        <col class="ticket-detail-product"/><col class="ticket-detail-money"/><col class="ticket-detail-money"/><col class="ticket-detail-money"/><col class="ticket-detail-money"/>
                    </colgroup>
                    <tbody>
                        <xsl:apply-templates select="item"/>
                        <xsl:if test="not(item)"><tr><td class="ticket-detail-product text-muted">Sin producto</td><td colspan="4"/></tr></xsl:if>
                        <tr class="ticket-total-row">
                            <td class="ticket-detail-product">
                                <xsl:text>Total ticket</xsl:text>
                                <xsl:if test="../@productos-filtrados='true'"><xsl:text> (todos los productos)</xsl:text></xsl:if>
                            </td>
                            <xsl:call-template name="importes"/>
                        </tr>
                    </tbody>
                </table>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="$billed">
                        <button type="button" class="badge text-bg-success border-0 fg-status" data-id="{@id}" data-action="unmark" title="Quitar marca de facturado">
                            <xsl:text>Facturado</xsl:text>
                            <xsl:if test="translate(normalize-space($source/@receptor),'FACTURADO','facturado')!='facturado'">
                                <xsl:text> · </xsl:text><xsl:value-of select="$source/@receptor"/>
                            </xsl:if>
                        </button>
                    </xsl:when>
                    <xsl:otherwise>
                        <button type="button" class="badge text-bg-warning border-0 fg-status" data-id="{@id}" data-action="mark" title="Marcar como facturado">No facturado</button>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="item">
        <tr>
            <td class="ticket-detail-product"><xsl:value-of select="@descripcion"/></td>
            <xsl:call-template name="importes"/>
        </tr>
    </xsl:template>

    <xsl:template name="importes">
        <td class="ticket-detail-money"><xsl:value-of select="@subtotal"/></td>
        <td class="ticket-detail-money"><xsl:value-of select="@iva"/></td>
        <td class="ticket-detail-money"><xsl:value-of select="@ieps"/></td>
        <td class="ticket-detail-money"><xsl:value-of select="@total"/></td>
    </xsl:template>
</xsl:stylesheet>
