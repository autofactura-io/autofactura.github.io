<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:session="http://panax.io/session"
    exclude-result-prefixes="session">
    <xsl:import href="~/widgets/page_controls.xslt"/>
    <xsl:param name="session:user_login"/>

    <xsl:template match="reporte[@modulo='ventas']" priority="1">
        <xsl:if test="normalize-space($session:user_login) != '' and translate(normalize-space($session:user_login),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') != 'mayorga' and @tenant='historica' and ventas-historica">
            <xsl:variable name="desde" select="substring(ventas-historica/@desde,1,7)"/>
            <xsl:variable name="hasta" select="substring(ventas-historica/@hasta,1,7)"/>
            <nav class="historica-meses" aria-label="Meses de los reportes de La Histórica" xo-scope="/*">
                <style><![CDATA[
                    #shell > footer:has(.historica-meses) { display: flex !important; }
                    #shell > footer:has(.historica-meses) > #page_controls { flex: 1 1 auto; width: 100%; min-width: 0; }
                    #shell > footer [id="page_controls"]:has(> .historica-meses) { width: 100%; min-width: 0; }
                    #shell > footer [id="page_controls"]:has(> .historica-meses) > [is="selection-summary"] { display: none; }
                    .historica-meses { display: flex; gap: .25rem; max-width: 100%; overflow-x: auto; padding: .25rem .2rem; }
                    .historica-meses button { flex: 0 0 auto; border: 1px solid #a9b4c0; border-radius: .3rem .3rem 0 0;
                        background: #f1f4f7; color: #203447; padding: .4rem .7rem; font-size: .76rem; font-weight: 600; white-space: nowrap; }
                    .historica-meses button:hover { background: #e3edf7; }
                    .historica-meses button[aria-current="date"] { background: #dcedf9; border-color: #517aa1; box-shadow: inset 0 -3px #185688; }
                ]]></style>
                <xsl:for-each select="periodos/mes">
                    <button type="button" data-portal-month="{@id}" onclick="this.dispatch('portal:mes')">
                        <xsl:if test="@id=$desde and @id=$hasta"><xsl:attribute name="aria-current">date</xsl:attribute></xsl:if>
                        <xsl:if test="../../@consultando"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                        <xsl:value-of select="@titulo"/>
                    </button>
                </xsl:for-each>
            </nav>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
