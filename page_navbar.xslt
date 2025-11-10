<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:metadata="http://panax.io/metadata"
xmlns:state="http://panax.io/state"
xmlns:initial="http://panax.io/state/initial"
xmlns:search="http://panax.io/state/search"
xmlns:env="http://panax.io/state/environment"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:widget="http://panax.io/widget"
xmlns:navbar="http://widgets.panaxbi.com/navbar"
xmlns:combobox="http://panax.io/widget/combobox"
>
	<xsl:import href="headers.xslt"/>
	<xsl:import href="common.xslt"/>
	<xsl:import href="widgets/page_navbar.xslt"/>
	<xsl:import href="widgets/combobox.xslt"/>

	<xsl:template mode="widget" match="@*|*"/>

	<xsl:param name="state:filterBy"></xsl:param>
	<xsl:param name="state:filterBy_1"></xsl:param>
	<xsl:param name="state:filterBy_2"></xsl:param>
	<xsl:param name="state:filterBy_3"></xsl:param>
	<xsl:param name="state:filterBy_4"></xsl:param>

	<xsl:key name="data" match="model/movimientos" use="'*'"/>
	<xsl:key name="data" match="model/ventas" use="'*'"/>
	<xsl:key name="data" match="model/trouble" use="'*'"/>

	<xsl:key name="changed" match="@initial:*" use="concat(../@xo:id,'::',local-name())"/>
	<xsl:template match="/">
		<span class="page-menu">
			<style>
				<![CDATA[
.page-menu nav {
    padding-right: 80px !important;
}

.page-menu {
    transition: 0.5s;
    height: var(--sections-filter-height, 0px);
	width: 100vw;
    /*display: flex;
    overflow-x: auto;
    overflow-y: hidden;*/
}

/* Works on Chrome, Edge, and Safari */
/*
.page-menu::-webkit-scrollbar {
  width: 12px;
}

.page-menu::-webkit-scrollbar-track {
  background: rgba(50, 62, 72, 0.9);
}

.page-menu::-webkit-scrollbar-thumb {
  background-color: orange;
  border-radius: 20px;
  border: 3px solid rgba(50, 62, 72, 0.9);
}*/
			
.navbar form {
    display: flex;
    flex-direction: row;
    padding-left: 0;
    margin-bottom: 0;
    list-style: none;
    margin-left: 23px;
}
			]]>
			</style>
			<style>
				:root { --sections-filter-height: 16px; }
			</style>
			<nav class="navbar navbar-expand-md">
				<form action="javascript:void(0);" onsubmit="section.source.fetch()">
					<xsl:apply-templates mode="navbar:widget" select="model"/>
					<!--<xsl:apply-templates mode="button" select="key('data','*')[not(*)]/@state:record_count[.&gt;0]"/>-->
				</form>
				<ul id="shell_buttons" class="nav col-md justify-content-end list-unstyled d-flex">
					<xsl:apply-templates mode="buttons"/>
				</ul>
			</nav>
		</span>
	</xsl:template>

	<xsl:template mode="buttons" match="*"/>

	<xsl:template mode="button" match="*/@state:record_count">
		<button class="btn btn-success text-nowrap" onclick="mostrarRegistros.call(this)" style="max-height: 38px; align-self: end;">
			Mostrar los <xsl:value-of select="."/> resultados
		</button>
	</xsl:template>
</xsl:stylesheet>