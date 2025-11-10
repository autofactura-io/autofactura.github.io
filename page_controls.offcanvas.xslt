<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:state="http://panax.io/state"
xmlns:session="http://panax.io/session"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
  <xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

  <xsl:template match="*[not(*)]|text()"/>
  <xsl:template match="/">
    <div xo-stylesheet="page_controls.offcanvas.xslt" class="col-md-12 d-flex align-items-center" xo-static="true">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="*">
    <style>
      <![CDATA[
			#offcanvasMantenibles { height: 40vh; }
			]]>
    </style>
    <xsl:variable name="show"></xsl:variable>
    <div class="offcanvas offcanvas-bottom {$show}" tabindex="-1" id="offcanvasMantenibles" aria-labelledby="offcanvasManteniblesLabel">
      <xsl:if test="$show='show'">
        <xsl:attribute name="aria-modal">true</xsl:attribute>
        <xsl:attribute name="role">dialog</xsl:attribute>
        <xsl:attribute name="style">visibility: visible;</xsl:attribute>
      </xsl:if>
    </div>
    <xsl:if test="$show='show'">
      <div class="modal-backdrop fade show"></div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
