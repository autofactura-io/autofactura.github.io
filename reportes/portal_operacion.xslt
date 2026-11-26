<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:session="http://panax.io/session"
    xmlns:meta="http://panax.io/metadata"
    exclude-result-prefixes="session meta">
    <xsl:import href="/reportes/portal_ventas_historica.xslt?v=20261125_5"/>
    <xsl:param name="session:user_login"/>
    <xsl:variable name="authorized" select="normalize-space($session:user_login) != '' and translate(normalize-space($session:user_login),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') != 'mayorga'"/>

    <xsl:template match="/reporte">
        <section class="container-fluid my-3" id="portal-operacion">
            <xsl:attribute name="data-portal-store"><xsl:choose><xsl:when test="@modulo='ventas'">#ventas</xsl:when><xsl:otherwise>#consulta_facturas</xsl:otherwise></xsl:choose></xsl:attribute>
            <style>#shell:has(#portal-operacion) > footer:has(.fg-summary-row) { display: none !important; }</style>
            <div class="card">
                <div class="card-body">
                    <h2 class="h4"><xsl:choose><xsl:when test="@modulo='ventas'">Ventas</xsl:when><xsl:otherwise>Facturas</xsl:otherwise></xsl:choose></h2>
                    <xsl:choose>
                        <xsl:when test="$authorized">
                            <p class="mt-3 mb-2" role="status">
                                <xsl:choose>
                                    <xsl:when test="@consultando">Consultando…</xsl:when>
                                    <xsl:when test="@error"><xsl:value-of select="@error"/></xsl:when>
                                    <xsl:when test="model"><xsl:value-of select="model/@meta:totalCount"/> tickets</xsl:when>
                                    <xsl:when test="ventas-historica"/>
                                    <xsl:when test="ventas"><xsl:value-of select="ventas/@tickets"/> tickets</xsl:when>
                                    <xsl:otherwise>Cargando consulta…</xsl:otherwise>
                                </xsl:choose>
                            </p>
                            <xsl:if test="@modulo='ventas' and not(ventas/grupo or ventas-historica)">
                                <p class="small text-muted mb-2">Elige un periodo y una vista en Filtros. Luego pulsa Consultar.</p>
                                <button class="btn btn-outline-primary btn-sm" type="button" onclick="xo.state.showFilters = true">Abrir filtros</button>
                            </xsl:if>
                            <xsl:if test="not(@error)"><xsl:apply-templates select="model|ventas|ventas-historica"/></xsl:if>

                        </xsl:when>
                        <xsl:otherwise><p>Este módulo no está disponible para tu cuenta.</p></xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
        </section>
    </xsl:template>

    <xsl:template match="ventas">
        <xsl:if test="../@agrupacion='mesero' and grupo[@nombre='Sin mesero registrado']">
            <p class="text-muted small">Los tickets sin mesero en los datos de origen aparecen agrupados como «Sin mesero registrado».</p>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="grupo">
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead><tr><th><xsl:choose><xsl:when test="../@agrupacion='mesero'">Mesero</xsl:when><xsl:when test="../@agrupacion='dia'">Fecha</xsl:when><xsl:when test="../@agrupacion='mes'">Mes</xsl:when><xsl:otherwise>Periodo</xsl:otherwise></xsl:choose></th><th>Tickets</th><th>Efectivo</th><th>Débito</th><th>Crédito</th><th>Socios</th><th>Otros</th><th>Total</th></tr></thead>
                        <tbody><xsl:apply-templates select="grupo"/></tbody>
                        <tfoot class="fw-bold"><xsl:call-template name="ventas-fila"><xsl:with-param name="nombre" select="'Total'"/></xsl:call-template></tfoot>
                    </table>
                </div>
            </xsl:when>
            <xsl:otherwise><p>Sin ventas en el periodo consultado.</p></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="grupo">
        <xsl:call-template name="ventas-fila"><xsl:with-param name="nombre" select="@nombre"/></xsl:call-template>
    </xsl:template>

    <xsl:template name="ventas-fila">
        <xsl:param name="nombre"/>
        <tr>
            <th scope="row"><xsl:value-of select="$nombre"/></th><td><xsl:value-of select="@tickets"/></td>
            <td><xsl:value-of select="format-number(@efectivo, '$#,##0.00')"/></td>
            <td><xsl:value-of select="format-number(@debito, '$#,##0.00')"/></td>
            <td><xsl:value-of select="format-number(@credito, '$#,##0.00')"/></td>
            <td><xsl:value-of select="format-number(@socios, '$#,##0.00')"/></td>
            <td><xsl:value-of select="format-number(@otros, '$#,##0.00')"/></td>
            <td><xsl:value-of select="format-number(@total, '$#,##0.00')"/></td>
        </tr>
    </xsl:template>

    <xsl:template match="model">
        <xsl:variable name="pages" select="ceiling(@meta:totalCount div @meta:pageSize)"/>
        <xsl:choose>
            <xsl:when test="row">
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead><tr><th>Fecha</th><th>Folio</th><th>Empresa</th><th>Sucursal</th><th>Estado</th><th>Receptor</th><th>Total</th></tr></thead>
                        <tbody><xsl:apply-templates select="row"/></tbody>
                    </table>
                </div>
                <nav class="d-flex gap-2 align-items-center" aria-label="Páginas de facturas">
                    <button class="btn btn-outline-secondary btn-sm" type="button" data-portal-page="{@meta:pageIndex - 1}" onclick="this.dispatch('portal:pagina')">
                        <xsl:if test="@meta:pageIndex &lt;= 1"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                        Anterior
                    </button>
                    <span>Página <xsl:value-of select="@meta:pageIndex"/> de <xsl:value-of select="$pages"/></span>
                    <button class="btn btn-outline-secondary btn-sm" type="button" data-portal-page="{@meta:pageIndex + 1}" onclick="this.dispatch('portal:pagina')">
                        <xsl:if test="@meta:pageIndex &gt;= $pages"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                        Siguiente
                    </button>
                </nav>
            </xsl:when>
            <xsl:otherwise><p>Sin tickets para los filtros seleccionados.</p></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="row">
        <xsl:variable name="receptor" select="normalize-space(@receptor)"/>
        <tr>
            <td><xsl:choose><xsl:when test="string-length(@dt)=8"><xsl:value-of select="concat(substring(@dt,1,4),'-',substring(@dt,5,2),'-',substring(@dt,7,2))"/></xsl:when><xsl:otherwise><xsl:value-of select="substring(@dt,1,10)"/></xsl:otherwise></xsl:choose></td>
            <td><xsl:value-of select="@tkt"/></td>
            <td><xsl:value-of select="@cte"/></td>
            <td><xsl:value-of select="@suc"/></td>
            <td><xsl:choose><xsl:when test="$receptor!=''">Facturado</xsl:when><xsl:otherwise>No facturado</xsl:otherwise></xsl:choose></td>
            <td><xsl:if test="translate($receptor,'FACTURADO','facturado')!='facturado'"><xsl:value-of select="$receptor"/></xsl:if></td>
            <td><xsl:value-of select="format-number(@t, '$#,##0.00')"/></td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
