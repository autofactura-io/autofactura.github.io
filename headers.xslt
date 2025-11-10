<!DOCTYPE stylesheet [
	<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:globalization="http://xover.dev/globalization"
  exclude-result-prefixes="xo xsl globalization"
>

	<xsl:template mode="globalization:headerText" match="@*|*" priority="-1">
		<xsl:value-of select="name()"/>	
	</xsl:template>
	
	<xsl:param name="globalization:headerText">#globalization</xsl:param>
	
	<xsl:template mode="headerText" match="@*|*">
		<xsl:apply-templates mode="globalization:headerText" select="."/>
	</xsl:template>

	<xsl:template mode="headerText" match="*[@nom]|*[@nom]/@*">
		<xsl:value-of select="ancestor-or-self::*[1]/@nom"/>
	</xsl:template>

  <xsl:template mode="headerText" match="*[@desc]|*[@desc]/@*">
    <xsl:value-of select="ancestor-or-self::*[1]/@desc"/>
  </xsl:template>

  <xsl:template mode="headerText" match="fecha/@mes">
		<xsl:value-of select="concat(substring(.,1,4),'-',substring(.,5))"/>
	</xsl:template>

	<xsl:template mode="headerText" match="fecha/@mes[substring(., string-length(.) - 1)='13' or string-length(.)=4]">
		<xsl:value-of select="substring(.,1,4)"/>
	</xsl:template>

	<xsl:template mode="headerText" match="model/*/@*">
		<xsl:value-of select="."/>
	</xsl:template>

  <xsl:template mode="headerText" match="*[@headerText]">
    <xsl:apply-templates select="@headerText"/>
  </xsl:template>
</xsl:stylesheet>