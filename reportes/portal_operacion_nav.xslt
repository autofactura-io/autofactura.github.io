<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:portal="http://autofactura.io/portal"
    exclude-result-prefixes="portal">
    <xsl:template match="/">
        <div class="portal-filter-outlet"><xsl:apply-templates select="reporte/filtros" mode="portal:filters"/></div>
    </xsl:template>

    <xsl:template match="reporte/filtros" mode="portal:filters">
        <form id="portal-operacion-filtros" class="portal-filter-form">
            <div class="offcanvas-body">
            <details class="ticket-filter-group" open="open">
                <summary>Empresa y sucursal</summary>
                <div class="ticket-filter-group-fields">
            <label>
                Empresa
                <select class="form-select" name="tenant" xo-slot="tenant" value="{@tenant}">
                    <option value="">Todas</option>
                    <xsl:for-each select="../catalogo/cliente">
                        <xsl:call-template name="option"><xsl:with-param name="value" select="@id"/><xsl:with-param name="label" select="@nombre"/><xsl:with-param name="selected" select="../../filtros/@tenant"/></xsl:call-template>
                    </xsl:for-each>
                </select>
            </label>
            <label>
                Sucursal
                <select class="form-select" name="sucursal" xo-slot="sucursal" value="{@sucursal}">
                    <option value="">Todas</option>
                    <xsl:variable name="tenant" select="@tenant"/>
                    <xsl:for-each select="../catalogo/cliente[not(string($tenant)) or @id=$tenant]/sucursal[not(@nombre = preceding::sucursal[not(string($tenant)) or parent::cliente/@id=$tenant]/@nombre)]">
                        <xsl:call-template name="option"><xsl:with-param name="value" select="@nombre"/><xsl:with-param name="selected" select="../../../filtros/@sucursal"/></xsl:call-template>
                    </xsl:for-each>
                </select>
            </label>
                </div>
            </details>
            <details class="ticket-filter-group" open="open">
                <summary>Consulta</summary>
                <div class="ticket-filter-group-fields">
            <label>Desde<input class="form-control" type="date" name="desde" xo-slot="desde" onchange="this.scope.set(this.value)" value="{@desde}"/></label>
            <label class="w-100">Hasta<input class="form-control" type="date" name="hasta" xo-slot="hasta" onchange="this.scope.set(this.value)" value="{@hasta}"/></label>
            <xsl:if test="../@modulo='ventas' and @tenant='historica'">
                    <label class="w-100">
                        Reporte
                        <select class="form-select" name="informe" xo-slot="informe" value="{@informe}">
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'diario'"/><xsl:with-param name="label" select="'Ventas diarias'"/><xsl:with-param name="selected" select="@informe"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'conciliacion'"/><xsl:with-param name="label" select="'Conciliación de tickets'"/><xsl:with-param name="selected" select="@informe"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'resumen'"/><xsl:with-param name="label" select="'Resumen de ventas'"/><xsl:with-param name="selected" select="@informe"/></xsl:call-template>
                        </select>
                    </label>
                    <xsl:if test="@informe != 'resumen'">
                    <label class="w-100">
                        Tickets borrados
                        <select class="form-select" name="borrados" xo-slot="borrados" value="{@borrados}">
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'ocultar'"/><xsl:with-param name="label" select="'Ocultar en el detalle'"/><xsl:with-param name="selected" select="@borrados"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'mostrar'"/><xsl:with-param name="label" select="'Mostrar en el detalle'"/><xsl:with-param name="selected" select="@borrados"/></xsl:call-template>
                        </select>
                    </label>
                    </xsl:if>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="../@modulo='ventas'">
                    <xsl:if test="@tenant!='historica' or @informe='resumen'">
                    <label class="w-100">
                        Vista
                        <select class="form-select" name="agrupacion" xo-slot="agrupacion" value="{@agrupacion}">
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'dia'"/><xsl:with-param name="label" select="'Por día'"/><xsl:with-param name="selected" select="@agrupacion"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'mes'"/><xsl:with-param name="label" select="'Por mes'"/><xsl:with-param name="selected" select="@agrupacion"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'mesero'"/><xsl:with-param name="label" select="'Por mesero'"/><xsl:with-param name="selected" select="@agrupacion"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'periodo'"/><xsl:with-param name="label" select="'Periodo abierto'"/><xsl:with-param name="selected" select="@agrupacion"/></xsl:call-template>
                        </select>
                    </label>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <label class="w-100">
                        Estado
                        <select class="form-select" name="estado" xo-slot="estado" value="{@estado}">
                            <option value="">Todos</option>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'Facturado'"/><xsl:with-param name="label" select="'Facturados'"/><xsl:with-param name="selected" select="@estado"/></xsl:call-template>
                            <xsl:call-template name="option"><xsl:with-param name="value" select="'No facturado'"/><xsl:with-param name="label" select="'No facturados'"/><xsl:with-param name="selected" select="@estado"/></xsl:call-template>
                        </select>
                    </label>
                </xsl:otherwise>
            </xsl:choose>
                </div>
            </details>
            </div>
            <div class="ticket-filter-actions"><button class="btn btn-primary w-100" type="submit"><xsl:if test="../@consultando"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>Consultar</button></div>
        </form>
    </xsl:template>

    <xsl:template name="option">
        <xsl:param name="value"/>
        <xsl:param name="label" select="$value"/>
        <xsl:param name="selected"/>
        <option value="{$value}">
            <xsl:if test="$value=$selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="$label"/>
        </option>
    </xsl:template>

</xsl:stylesheet>
