<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">
    <xsl:template match="ventas-historica">
        <xsl:variable name="formato" select="../formatos/formato[@id=current()/@informe]"/>
        <xsl:variable name="mes" select="../periodos/mes[@id=substring(current()/@desde,1,7) and @id=substring(current()/@hasta,1,7)]"/>
        <section class="historica" aria-labelledby="ventas-historica-titulo">
            <style><![CDATA[
                .historica {
                    --historica-venta-previa: #92d050;
                    --historica-efectivo-corte: #fff386;
                    --historica-rasurado: #b4c6e7;
                    --historica-deposito: #fff49a;
                }
                .historica-colores {
                    display: flex; flex-wrap: wrap; gap: .25rem 1rem;
                    margin: 0 0 .5rem; padding: 0; list-style: none; color: #4b5563; font-size: .75rem;
                }
                .historica-colores li { display: inline-flex; gap: .35rem; align-items: center; }
                .historica-colores span {
                    inline-size: .72rem; block-size: .72rem; flex: 0 0 auto; border: 1px solid #7b8086; border-radius: 2px;
                }
                .historica-colores .venta-previa { background: var(--historica-venta-previa); }
                .historica-colores .efectivo-corte { background: var(--historica-efectivo-corte); }
                .historica-colores .rasurado { background: var(--historica-rasurado); }
                .historica-colores .deposito { background: var(--historica-deposito); inline-size: 1.4rem; }
                .historica-sheet {
                    border: 1px solid #87929c; background: #fff; overflow: auto;
                    max-block-size: 66vh; max-block-size: 66dvh; scroll-padding-block-start: 1.5rem;
                }
                .historica-table { margin: 0; width: max-content; min-width: 100%; border-collapse: separate; border-spacing: 0; font: .78rem/1.25 Calibri, Arial, sans-serif; color: #111; }
                .historica-table th, .historica-table td { vertical-align: middle; white-space: nowrap; padding: .06rem .34rem; border: solid #404040; border-width: 0 1px 1px 0; }
                .historica-table tr > :last-child { border-right: 0; }
                .historica-table thead th {
                    position: sticky; top: 0; z-index: 2; background: #9bc2e6; font-weight: 700;
                }
                .historica-table thead th:first-child { left: 0; z-index: 3; }
                .historica-conciliacion thead th { background: #ffd966; }
                .historica-table tbody th { background: #fff; }
                .historica-table tbody th[scope="row"], .historica-table tfoot th {
                    position: sticky; left: 0; z-index: 1;
                }
                .historica-table tfoot th, .historica-table tfoot td { background: #e5e8eb; border-top: 2px solid #566573; border-bottom: 0; font-weight: 700; }
                .historica-table .venta-previa { background: var(--historica-venta-previa); }
                .historica-table .efectivo-corte { background: var(--historica-efectivo-corte); }
                .historica-table .rasurado { background: var(--historica-rasurado); }
                .historica-table .historica-con-deposito > * { background: var(--historica-deposito); }
                .historica-table .historica-dia {
                    display: inline-flex; align-items: center; justify-content: space-between; gap: .25rem;
                    min-inline-size: 2.35rem; min-block-size: 1.35rem; padding: 0 .3rem;
                    border: 1px solid #8299af; border-radius: .25rem; color: #173b5c;
                    background: #f7faff; font: inherit; font-weight: 650; vertical-align: middle; cursor: pointer;
                }
                .historica-table .historica-dia:hover { background: #e9f2fc; }
                .historica-table .historica-dia:focus-visible { outline: 2px solid #17599a; outline-offset: 1px; }
                .historica-table .historica-dia[aria-expanded="true"] { background: #dbeafa; border-color: #527da3; }
                .historica-dia-icon { inline-size: .65rem; text-align: center; }
                .historica-dia-icon::before { content: "+"; }
                .historica-dia[aria-expanded="true"] .historica-dia-icon::before { content: "−"; }
                .historica-table .historica-detalle > td { background: #f1f6fa; padding: .8rem; white-space: normal; }
                .historica-detalle-panel { position: sticky; left: .8rem; width: min(85vw, 53rem); max-width: 100%; }
                .historica-detalle-panel td, .historica-detalle-panel th { border: 0; border-bottom: 1px solid #d4dee7; }
            ]]></style>
            <h3 class="h5 mb-1">LA CONVIVENCIA GASTRONÓMICA</h3>
            <div class="d-flex flex-wrap justify-content-between gap-2 mb-2">
                <h4 id="ventas-historica-titulo" class="h6 m-0"><xsl:choose>
                    <xsl:when test="@informe='conciliacion'">RASURADO</xsl:when>
                    <xsl:otherwise>VENTAS DIARIAS</xsl:otherwise>
                </xsl:choose></h4>
                <span class="small text-muted"><xsl:choose>
                    <xsl:when test="$mes and @desde=$mes/@desde and @hasta=$mes/@hasta"><xsl:value-of select="$mes/@titulo"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="@desde"/> al <xsl:value-of select="@hasta"/></xsl:otherwise>
                </xsl:choose></span>
            </div>
            <xsl:if test="not(corte)"><p class="small text-muted" role="status">Sin respaldos oficiales cargados para el periodo seleccionado.</p></xsl:if>
            <xsl:if test="$formato and (dia or $mes)">
                <ul id="ventas-historica-colores" class="historica-colores" aria-label="Colores de la tabla">
                    <xsl:if test="@informe='conciliacion'">
                        <li><span class="venta-previa" aria-hidden="true"/>Venta previa</li>
                        <li><span class="efectivo-corte" aria-hidden="true"/>Efectivo después del rasurado</li>
                        <li><span class="rasurado" aria-hidden="true"/>Importe rasurado</li>
                    </xsl:if>
                    <li><span class="deposito" aria-hidden="true"/>Fila amarilla: fecha de depósito registrada</li>
                </ul>
                <div class="table-responsive historica-sheet" tabindex="0" role="region" aria-labelledby="ventas-historica-titulo">
                    <table class="historica-table historica-{@informe}" aria-labelledby="ventas-historica-titulo" aria-describedby="ventas-historica-colores">
                        <thead><tr><th scope="col">DÍA</th>
                            <xsl:for-each select="$formato/columna">
                                <th scope="col" class="text-end">
                                    <xsl:if test="@campo='facturacion'"><xsl:attribute name="title">Estimación del reporte: venta previa menos diferencia de efectivo</xsl:attribute></xsl:if>
                                    <xsl:value-of select="@titulo"/>
                                </th>
                            </xsl:for-each>
                        </tr></thead>
                        <tbody>
                            <xsl:choose>
                                <xsl:when test="$mes">
                                    <xsl:call-template name="historica-dias-mes">
                                        <xsl:with-param name="reporte" select="."/>
                                        <xsl:with-param name="columnas" select="$formato/columna"/>
                                        <xsl:with-param name="mes" select="$mes/@id"/>
                                        <xsl:with-param name="ultimo" select="number(substring($mes/@hasta,9,2))"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="dia">
                                        <xsl:call-template name="historica-fila">
                                            <xsl:with-param name="datos" select="."/>
                                            <xsl:with-param name="columnas" select="$formato/columna"/>
                                            <xsl:with-param name="fecha" select="@fecha"/>
                                            <xsl:with-param name="etiqueta" select="@fecha"/>
                                            <xsl:with-param name="detalle" select="../../detalle-dia[@fecha=current()/@fecha]"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tbody>
                        <tfoot><tr><th scope="row">TOTAL</th>
                            <xsl:call-template name="historica-celdas">
                                <xsl:with-param name="datos" select="totales"/>
                                <xsl:with-param name="columnas" select="$formato/columna"/>
                                <xsl:with-param name="facturable" select="boolean(dia[@total]) and not(dia[@total and not(@ventaPrevia and @diferencia)])"/>
                            </xsl:call-template>
                        </tr></tfoot>
                    </table>
                </div>
                <p class="small text-muted mt-2 mb-2">El guion indica que falta un dato. Importe e IVA provienen del corte de Soft Restaurant.
                    <xsl:if test="@informe='conciliacion'"> <xsl:if test="@rasuradoVersion"> En Rasurado, * indica un importe tomado del Excel total o parcialmente. Solo los días con cambios identificados abren el detalle.</xsl:if> Facturación SAT es el cálculo del Excel por día y su suma en el periodo.</xsl:if>
                </p>
            </xsl:if>
            <xsl:if test="corte">
                <details class="mb-2">
                    <summary>Respaldos utilizados</summary>
                    <ul class="mb-1"><xsl:for-each select="corte"><li>
                        <xsl:value-of select="@sucursal"/> · <xsl:value-of select="@mes"/> · Corte <xsl:value-of select="@oficial"/>
                        <xsl:if test="@previo"> · Previo <xsl:value-of select="@previo"/></xsl:if>
                        <xsl:if test="@comparado='0'"> · Sin respaldo previo comparable</xsl:if>
                    </li></xsl:for-each></ul>
                </details>
            </xsl:if>
            <xsl:if test="detalle">
                <details class="mb-2">
                    <summary>Cambios de tickets del periodo</summary>
                    <xsl:apply-templates select="detalle"/>
                </details>
            </xsl:if>
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
        </section>
    </xsl:template>

    <xsl:template name="historica-dias-mes">
        <xsl:param name="reporte"/>
        <xsl:param name="columnas"/>
        <xsl:param name="mes"/>
        <xsl:param name="ultimo"/>
        <xsl:param name="dia" select="1"/>
        <xsl:variable name="fecha" select="concat($mes,'-',format-number($dia,'00'))"/>
        <xsl:call-template name="historica-fila">
            <xsl:with-param name="datos" select="$reporte/dia[@fecha=$fecha]"/>
            <xsl:with-param name="columnas" select="$columnas"/>
            <xsl:with-param name="fecha" select="$fecha"/>
            <xsl:with-param name="etiqueta" select="$dia"/>
            <xsl:with-param name="detalle" select="$reporte/../detalle-dia[@fecha=$fecha]"/>
        </xsl:call-template>
        <xsl:if test="$dia &lt; $ultimo">
            <xsl:call-template name="historica-dias-mes">
                <xsl:with-param name="reporte" select="$reporte"/>
                <xsl:with-param name="columnas" select="$columnas"/>
                <xsl:with-param name="mes" select="$mes"/>
                <xsl:with-param name="ultimo" select="$ultimo"/>
                <xsl:with-param name="dia" select="$dia + 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="historica-fila">
        <xsl:param name="datos"/>
        <xsl:param name="columnas"/>
        <xsl:param name="fecha"/>
        <xsl:param name="etiqueta"/>
        <xsl:param name="detalle"/>
        <tr>
            <xsl:if test="normalize-space($datos/@depositoFecha) != ''"><xsl:attribute name="class">historica-con-deposito</xsl:attribute></xsl:if>
            <th scope="row" class="text-end">
                <xsl:choose>
                    <xsl:when test="$datos[@tieneDetalle='1' or not(@tieneDetalle)]">
                        <button type="button" class="historica-dia" data-portal-day="{$fecha}"
                            aria-label="Cambios de tickets del {$fecha}" title="Mostrar u ocultar cambios de tickets"
                            aria-expanded="{boolean($detalle)}" onclick="this.dispatch('portal:dia')">
                            <xsl:if test="$detalle">
                                <xsl:attribute name="aria-controls">historica-detalle-<xsl:value-of select="$fecha"/></xsl:attribute>
                            </xsl:if>
                            <span class="historica-dia-icon" aria-hidden="true"></span>
                            <span><xsl:value-of select="$etiqueta"/></span>
                        </button>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$etiqueta"/></xsl:otherwise>
                </xsl:choose>
            </th>
            <xsl:call-template name="historica-celdas">
                <xsl:with-param name="datos" select="$datos"/>
                <xsl:with-param name="columnas" select="$columnas"/>
            </xsl:call-template>
        </tr>
        <xsl:if test="$detalle">
            <tr class="historica-detalle" id="historica-detalle-{$fecha}"><td colspan="{count($columnas) + 1}">
                <section class="historica-detalle-panel" aria-label="Cambios de tickets del {$fecha}">
                    <h5 class="h6 mb-2">Cambios de tickets del <xsl:value-of select="$fecha"/></h5>
                    <xsl:choose>
                        <xsl:when test="$detalle/@consultando"><p class="mb-0" role="status">Consultando cambios…</p></xsl:when>
                        <xsl:when test="$detalle/@error">
                            <p class="mb-2" role="alert"><xsl:value-of select="$detalle/@error"/></p>
                            <button type="button" class="btn btn-sm btn-outline-secondary" data-portal-day="{$fecha}"
                                data-portal-page="{$detalle/@pagina}" onclick="this.dispatch('portal:dia')">Reintentar</button>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$detalle/ventas-historica/detalle">
                                <xsl:with-param name="fecha" select="$fecha"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </section>
            </td></tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="historica-celdas">
        <xsl:param name="datos"/>
        <xsl:param name="columnas"/>
        <xsl:param name="facturable" select="true()"/>
        <xsl:for-each select="$columnas">
            <xsl:variable name="campo" select="@campo"/>
            <xsl:variable name="valor">
                <xsl:choose>
                    <xsl:when test="$campo='rasurado' and not($datos/../@rasuradoVersion)">
                        <xsl:value-of select="$datos/@diferencia"/>
                    </xsl:when>
                    <xsl:when test="$campo='facturacion'">
                        <xsl:if test="$facturable and $datos/@ventaPrevia and $datos/@diferencia">
                            <xsl:value-of select="$datos/@ventaPrevia - $datos/@diferencia"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$datos/@*[local-name()=$campo]"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$campo='depositoFecha'"><td class="text-end"><xsl:value-of select="$valor"/></td></xsl:when>
                <xsl:otherwise><xsl:call-template name="historica-importe">
                    <xsl:with-param name="valor" select="$valor"/>
                    <xsl:with-param name="clase" select="@clase"/>
                    <xsl:with-param name="fuente" select="$datos/@rasuradoFuente[$campo='rasurado']"/>
                    <xsl:with-param name="reportado" select="$datos/@rasuradoExcel[$campo='rasurado']"/>
                </xsl:call-template></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="detalle">
        <xsl:param name="fecha"/>
        <xsl:if test="@borrados &gt; 0">
            <p class="small text-muted mb-2">Tickets borrados identificados: <xsl:value-of select="@borrados"/>.
                <xsl:if test="../@mostrarBorrados='0'"> El filtro los oculta de la tabla.</xsl:if>
            </p>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ticket">
                <p class="small text-muted mb-2">Tickets borrados, renumerados o por conciliar entre respaldos.</p>
                <div class="table-responsive">
                    <table class="table table-sm align-middle mb-2">
                        <thead><tr>
                            <xsl:if test="not($fecha)"><th scope="col">Fecha</th></xsl:if>
                            <th scope="col">Sucursal</th><th scope="col">Cheque</th><th scope="col">Folio previo</th>
                            <th scope="col">Folio del corte</th><th scope="col">Estado</th>
                            <th scope="col" class="text-end">Importe previo</th><th scope="col" class="text-end">Importe del corte</th>
                        </tr></thead>
                        <tbody><xsl:for-each select="ticket"><tr>
                            <xsl:if test="not($fecha)"><td><xsl:value-of select="@fecha"/></td></xsl:if>
                            <td><xsl:value-of select="@sucursal"/></td>
                            <td><xsl:if test="@serie='1'">A-</xsl:if><xsl:value-of select="@cheque"/></td>
                            <td><xsl:value-of select="@folioPrevio"/></td><td><xsl:value-of select="@folioOficial"/></td>
                            <td><xsl:choose>
                                <xsl:when test="@estado='Borrado'"><span class="badge bg-warning text-dark">Borrado</span></xsl:when>
                                <xsl:otherwise><xsl:value-of select="@estado"/></xsl:otherwise>
                            </xsl:choose></td>
                            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@importePrevio"/></xsl:call-template>
                            <xsl:call-template name="historica-importe"><xsl:with-param name="valor" select="@importeOficial"/></xsl:call-template>
                        </tr></xsl:for-each></tbody>
                    </table>
                </div>
                <xsl:if test="@paginas &gt; 1">
                    <nav class="d-flex gap-2 align-items-center" aria-label="Páginas de cambios entre respaldos">
                        <xsl:call-template name="historica-pagina"><xsl:with-param name="fecha" select="$fecha"/><xsl:with-param name="pagina" select="@pagina - 1"/><xsl:with-param name="etiqueta" select="'Anterior'"/></xsl:call-template>
                        <span>Página <xsl:value-of select="@pagina"/> de <xsl:value-of select="@paginas"/></span>
                        <xsl:call-template name="historica-pagina"><xsl:with-param name="fecha" select="$fecha"/><xsl:with-param name="pagina" select="@pagina + 1"/><xsl:with-param name="etiqueta" select="'Siguiente'"/></xsl:call-template>
                    </nav>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <p class="mb-0"><xsl:choose>
                    <xsl:when test="../@mostrarBorrados='0' and @borrados &gt; 0">No hay otros cambios para mostrar.</xsl:when>
                    <xsl:when test="not(../corte[@comparado='1'])">Falta un respaldo previo comparable para identificar cambios.</xsl:when>
                    <xsl:otherwise>Los respaldos comparados no muestran tickets borrados, renumerados ni por conciliar.</xsl:otherwise>
                </xsl:choose></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="historica-pagina">
        <xsl:param name="fecha"/>
        <xsl:param name="pagina"/>
        <xsl:param name="etiqueta"/>
        <button type="button" class="btn btn-outline-secondary btn-sm" data-portal-page="{$pagina}">
            <xsl:choose>
                <xsl:when test="$fecha">
                    <xsl:attribute name="data-portal-day"><xsl:value-of select="$fecha"/></xsl:attribute>
                    <xsl:attribute name="onclick">this.dispatch('portal:dia')</xsl:attribute>
                </xsl:when>
                <xsl:otherwise><xsl:attribute name="onclick">this.dispatch('portal:pagina')</xsl:attribute></xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$pagina &lt; 1 or $pagina &gt; @paginas"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
            <xsl:value-of select="$etiqueta"/>
        </button>
    </xsl:template>

    <xsl:template name="historica-importe">
        <xsl:param name="valor"/>
        <xsl:param name="clase"/>
        <xsl:param name="fuente"/>
        <xsl:param name="reportado"/>
        <td class="text-end text-nowrap {$clase}">
            <xsl:if test="$fuente">
                <xsl:attribute name="title">
                    <xsl:choose>
                        <xsl:when test="$fuente='excel'">Rasurado reportado en Excel</xsl:when>
                        <xsl:when test="$fuente='mixto'">Rasurado de Excel y respaldos de distintas sucursales</xsl:when>
                        <xsl:otherwise>Rasurado por comparación de respaldos</xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$fuente='respaldos' and $reportado and number($reportado) != number($valor)">
                        <xsl:text>. Importe en Excel </xsl:text>
                        <xsl:value-of select="format-number($reportado, '$#,##0.00;-$#,##0.00')"/>
                    </xsl:if>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="normalize-space($valor) != ''"><xsl:value-of select="format-number($valor, '$#,##0.00;-$#,##0.00')"/></xsl:when>
                <xsl:otherwise>—</xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$fuente='excel' or $fuente='mixto'">
                <sup aria-label="Importe reportado en Excel">*</sup>
            </xsl:if>
        </td>
    </xsl:template>
</xsl:stylesheet>
