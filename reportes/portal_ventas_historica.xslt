<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">
    <xsl:template match="ventas-historica">
        <section aria-labelledby="ventas-historica-titulo">
            <h3 id="ventas-historica-titulo" class="h5 mb-2">
                <xsl:choose>
                    <xsl:when test="@informe='conciliacion'">Conciliación de tickets</xsl:when>
                    <xsl:otherwise>Ventas diarias</xsl:otherwise>
                </xsl:choose>
            </h3>
            <p class="text-muted mb-3"><xsl:value-of select="@desde"/> al <xsl:value-of select="@hasta"/></p>
            <xsl:choose>
                <xsl:when test="corte">
                    <details class="mb-3">
                        <summary>Respaldos utilizados</summary>
                        <ul class="mb-1">
                            <xsl:for-each select="corte">
                                <li>
                                    <xsl:value-of select="@sucursal"/> · <xsl:value-of select="@mes"/> ·
                                    Corte <xsl:value-of select="@oficial"/>
                                    <xsl:if test="@previo"> · Previo <xsl:value-of select="@previo"/></xsl:if>
                                    <xsl:if test="@comparado='0'"> · Sin respaldo previo comparable</xsl:if>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </details>
                    <xsl:choose>
                        <xsl:when test="dia">
                            <div class="table-responsive">
                                <table class="table table-sm table-striped align-middle text-nowrap">
                                    <thead><tr>
                                        <th scope="col">Fecha</th>
                                        <xsl:if test="@informe='conciliacion'">
                                            <th scope="col" class="text-end">Venta previa</th>
                                            <th scope="col" class="text-end">Venta previa + propina</th>
                                            <th scope="col" class="text-end">Efectivo y tarjeta previos</th>
                                        </xsl:if>
                                        <th scope="col" class="text-end">Efectivo previo</th>
                                        <th scope="col" class="text-end">Efectivo del corte</th>
                                        <th scope="col" class="text-end">Diferencia de efectivo</th>
                                        <th scope="col" class="text-end">Tarjeta</th>
                                        <th scope="col" class="text-end">CxC</th>
                                        <th scope="col" class="text-end">Vales</th>
                                        <th scope="col" class="text-end">Propina</th>
                                        <th scope="col" class="text-end">Recibido</th>
                                        <th scope="col" class="text-end">Importe</th>
                                        <th scope="col" class="text-end">IVA</th>
                                        <th scope="col" class="text-end">Total del corte</th>
                                        <th scope="col" class="text-end">Egresos</th>
                                        <th scope="col" class="text-end">A depositar</th>
                                        <th scope="col">Fecha de depósito</th>
                                        <th scope="col" class="text-end">Depositado</th>
                                        <th scope="col" class="text-end">Propina estimada (5 %)</th>
                                        <th scope="col" class="text-end">Egresos en efectivo</th>
                                    </tr></thead>
                                    <tbody><xsl:apply-templates select="dia" mode="ventas-historica"/></tbody>
                                    <tfoot class="fw-bold"><xsl:apply-templates select="totales" mode="ventas-historica"/></tfoot>
                                </table>
                            </div>
                            <p class="small text-muted">El guion indica que falta un respaldo previo comparable o una captura de caja. La propina estimada corresponde al 5 % de la venta previa.</p>
                        </xsl:when>
                        <xsl:otherwise><p>Los respaldos cargados no contienen ventas en el periodo.</p></xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="detalle"/>
                    <xsl:if test="egresos/egreso">
                        <details>
                            <summary>Egresos en efectivo capturados en Excel</summary>
                            <div class="table-responsive">
                                <table class="table table-sm">
                                    <thead><tr><th>Mes</th><th>Concepto</th><th class="text-end">Importe</th></tr></thead>
                                    <tbody><xsl:for-each select="egresos/egreso"><tr>
                                        <td><xsl:value-of select="@mes"/></td><td><xsl:value-of select="@concepto"/></td>
                                        <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@importe"/></xsl:call-template>
                                    </tr></xsl:for-each></tbody>
                                </table>
                            </div>
                        </details>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise><p>Sin respaldos oficiales cargados para los filtros seleccionados.</p></xsl:otherwise>
            </xsl:choose>
        </section>
    </xsl:template>

    <xsl:template match="dia|totales" mode="ventas-historica">
        <tr>
            <th scope="row"><xsl:choose><xsl:when test="@fecha"><xsl:value-of select="@fecha"/></xsl:when><xsl:otherwise>Total</xsl:otherwise></xsl:choose></th>
            <xsl:if test="../@informe='conciliacion'">
                <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@ventaPrevia"/></xsl:call-template>
                <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@ventaPreviaConPropina"/></xsl:call-template>
                <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@cobrosPrevios"/></xsl:call-template>
            </xsl:if>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@efectivoPrevio"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@efectivo"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@diferencia"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@tarjeta"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@cxc"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@vales"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@propina"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@recibido"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@importe"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@iva"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@total"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@egresos"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@porDepositar"/></xsl:call-template>
            <td><xsl:value-of select="@depositoFecha"/></td>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@depositado"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@propinaEstimada"/></xsl:call-template>
            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@egresosEfectivo"/></xsl:call-template>
        </tr>
    </xsl:template>

    <xsl:template match="detalle">
        <section class="mt-3" aria-labelledby="ventas-historica-detalle">
            <h4 id="ventas-historica-detalle" class="h6">Cambios entre respaldos</h4>
            <p class="small text-muted"><xsl:value-of select="@borrados"/> tickets borrados identificados.
                <xsl:if test="../@mostrarBorrados='0'"> El filtro los oculta de la tabla.</xsl:if>
            </p>
            <xsl:choose>
                <xsl:when test="ticket">
                    <div class="table-responsive">
                        <table class="table table-sm align-middle">
                            <thead><tr><th>Fecha</th><th>Sucursal</th><th>Cheque</th><th>Folio previo</th><th>Folio del corte</th><th>Estado</th><th class="text-end">Importe previo</th><th class="text-end">Importe del corte</th></tr></thead>
                            <tbody><xsl:for-each select="ticket"><tr>
                                <td><xsl:value-of select="@fecha"/></td>
                                <td><xsl:value-of select="@sucursal"/></td>
                                <td><xsl:if test="@serie='1'">A-</xsl:if><xsl:value-of select="@cheque"/></td>
                                <td><xsl:value-of select="@folioPrevio"/></td>
                                <td><xsl:value-of select="@folioOficial"/></td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="@estado='Borrado'"><span class="badge bg-warning text-dark">Borrado</span></xsl:when>
                                        <xsl:otherwise><xsl:value-of select="@estado"/></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@importePrevio"/></xsl:call-template>
                                <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@importeOficial"/></xsl:call-template>
                            </tr></xsl:for-each></tbody>
                        </table>
                    </div>
                    <xsl:if test="@paginas &gt; 1">
                        <nav class="d-flex gap-2 align-items-center" aria-label="Páginas de conciliación">
                            <button type="button" class="btn btn-outline-secondary btn-sm" data-portal-page="{@pagina - 1}" onclick="this.dispatch('portal:pagina')">
                                <xsl:if test="@pagina &lt;= 1"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                                Anterior
                            </button>
                            <span>Página <xsl:value-of select="@pagina"/> de <xsl:value-of select="@paginas"/></span>
                            <button type="button" class="btn btn-outline-secondary btn-sm" data-portal-page="{@pagina + 1}" onclick="this.dispatch('portal:pagina')">
                                <xsl:if test="@pagina &gt;= @paginas"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                                Siguiente
                            </button>
                        </nav>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise><p>Sin cambios para mostrar con estos filtros.</p></xsl:otherwise>
            </xsl:choose>
        </section>
    </xsl:template>

    <xsl:template name="historica-importe">
        <xsl:param name="valor"/>
        <td class="text-end text-nowrap">
            <xsl:choose>
                <xsl:when test="string($valor) != ''"><xsl:value-of select="format-number($valor, '$#,##0.00')"/></xsl:when>
                <xsl:otherwise>—</xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>
</xsl:stylesheet>
