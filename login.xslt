<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:login="http://widgets.panaxbi.com/login"
>
	<xsl:include href="widgets/login.xslt"/>

	<xsl:attribute-set name="login:widget">
		<xsl:attribute name="style">
			background-position: center center;
			background-repeat: no-repeat;
			background-size: cover;
			background-image: url(assets/background.jpg);
			display: flex;
			align-items: end;
		</xsl:attribute>
	</xsl:attribute-set>
</xsl:stylesheet>