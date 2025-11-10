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
	<xsl:key name="sitemap-item" match="item" use="'#any'"/>
	<xsl:key name="sitemap-menu-item" match="item[item]" use="@xo:id"/>

	<xsl:include href="widgets/sitemap.xslt"/>
</xsl:stylesheet>
