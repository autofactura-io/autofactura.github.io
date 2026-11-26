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
xmlns:session="http://panax.io/session"
exclude-result-prefixes="session"
>
	<xsl:import href="headers.xslt"/>
	<xsl:import href="common.xslt"/>
	<xsl:import href="~/widgets/page_navbar.xslt"/>
	<xsl:import href="widgets/combobox.xslt"/>

	<xsl:param name="session:user_login"/>

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
			
.page-menu nav:has(select[xo-slot][name="sentido"]) { padding-right: 1rem !important; }
.page-menu form:has(select[xo-slot][name="sentido"]) { flex-wrap: wrap; align-items: end; gap: .5rem; }
.page-menu fieldset:has(> #cfdi-sentido),
.page-menu fieldset:has(> #cfdi-estatus) { min-width: 9rem; flex: 0 1 auto; }

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
				<xsl:choose>
					<xsl:when test="reporte/filtros">
						<xsl:if test="normalize-space($session:user_login) != '' and translate(normalize-space($session:user_login),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') != 'mayorga'">
							<div class="portal-filter-section"
								xo-store="active" xo-stylesheet="/reportes/portal_operacion_nav.xslt?v=20261126_7"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<form action="javascript:void(0);" onsubmit="section.source.fetch()">
							<xsl:apply-templates mode="navbar:widget" select="model"/>
						</form>
					</xsl:otherwise>
				</xsl:choose>
				<ul id="shell_buttons" class="nav col-md justify-content-end list-unstyled d-flex">
					<xsl:apply-templates mode="buttons"/>
				</ul>
			</nav>
		</span>
	</xsl:template>

	<xsl:template mode="widget" match="model[sentido[@navbar:control='select'] and estatus[@navbar:control='select']]/fecha_consultada[@navbar:control='daterange']" priority="2">
		<px-daterange name="{name()}" class="input-group" value="{@state:selected}" xo-slot="state:selected" picker="flatpickr" label="{@navbar:headerText}">
			<xsl:attribute name="max">{{new Date().toISOString().slice(0,10)}}</xsl:attribute>
		</px-daterange>
	</xsl:template>

	<xsl:template mode="widget" match="model/sentido[@navbar:control='select']|model/estatus[@navbar:control='select']" priority="2">
		<xsl:variable name="selected" select="@state:selected"/>
		<select id="cfdi-{name()}" name="{name()}" class="form-select" aria-label="{@navbar:headerText}" xo-slot="state:selected" value="{$selected}">
			<xsl:for-each select="row">
				<option value="{@key}">
					<xsl:if test="@key=$selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
					<xsl:value-of select="@desc"/>
				</option>
			</xsl:for-each>
		</select>
	</xsl:template>
	<xsl:template mode="buttons" match="*"/>

	<xsl:template mode="button" match="*/@state:record_count">
		<button class="btn btn-success text-nowrap" onclick="mostrarRegistros.call(this)" style="max-height: 38px; align-self: end;">
			Mostrar los <xsl:value-of select="."/> resultados
		</button>
	</xsl:template>
</xsl:stylesheet>