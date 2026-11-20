<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:xo="http://panax.io/xover"
exclude-result-prefixes="#default session sitemap shell state"
>
	<xsl:import href="~/widgets/sitemap.xslt"/>
	<xsl:param name="session:user_login"/>
	<xsl:key name="sitemap-item" match="item" use="'#any'"/>
	<xsl:key name="sitemap-menu-item" match="item[item]" use="@xo:id"/>

	<xsl:template match="item[@target and not(item)]" mode="sitemap:widget" priority="10">
		<xsl:variable name="isMayorga" select="translate(normalize-space($session:user_login),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='mayorga'"/>
		<xsl:if test="$isMayorga = (@target='#resumen_descarga_cfdi')">
			<li class="sidebar-item">
				<a class="sidebar-link">
					<xsl:apply-templates select="." mode="sitemap:target-href"/>
					<xsl:value-of select="@title"/>
				</a>
			</li>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
