<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:xlink="http://www.w3.org/1999/xlink"
>
	<xsl:include href="widgets/shell/shell.xslt?v=6073228"/>

	<xsl:template match="/">
		<script src="/widgets/shell/sidebar-availability.js"/>
		<script src="/widgets/shell/shell.js?v=261113"/>
		<xsl:apply-templates mode="shell:widget"/>
	</xsl:template>

	<xsl:template mode="shell:page-menu" match="*" priority="1">
		<span class="page-menu" xo-source="active" xo-stylesheet="/page_navbar.xslt?v=20261125_7"/>
	</xsl:template>

	<xsl:template mode="shell:sitemap" match="*" priority="1">
		<aside class="sidebar" xo-source="#sitemap" xo-stylesheet="/sitemap.xslt" id="sitemap"/>
	</xsl:template>

	<xsl:attribute-set name="shell:logo">
		<xsl:attribute name="src">assets/logotype.png</xsl:attribute>
	</xsl:attribute-set>
</xsl:stylesheet>
