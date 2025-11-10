<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:site="http://panax.io/site"
xmlns:state="http://panax.io/state"
xmlns:initial="http://panax.io/state/initial"
xmlns:env="http://panax.io/state/environment"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
	<xsl:param name="site:seed">''</xsl:param>
	<xsl:param name="state:touched"/>

	<xsl:template match="/">
		<div id="page_controls" class="col-md-12 d-flex align-items-center">
			<style>
				<![CDATA[
        :root { --footer-height: 34px; }

        .filters-toggle {
          background: #343a40;
          color: #fff;
          position: fixed;
          bottom: var(--footer-height);
          z-index: 1002;
          right: 0;
          width: 46px;
          padding: .75rem;
          border-top-left-radius: .2rem;
          border-bottom-left-radius: .2rem;
          box-shadow: -5px 0 10px 0 rgba(0,0,0,.1);
          -webkit-transition: all .1s ease-in-out;
          transition: all .1s ease-in-out;
          cursor: pointer;
		  margin-right: var(--scrollbar-width,0);
        }

        .filters-toggle:hover {
          width: 52px;
        }

        .filters-toggle svg {
          width: 22px;
          height: 22px;
          -webkit-animation-name: spin;
          animation-name: spin;
          -webkit-animation-duration: 4s;
          animation-duration: 4s;
          -webkit-animation-iteration-count: infinite;
          animation-iteration-count: infinite;
          -webkit-animation-timing-function: linear;
          animation-timing-function: linear
        }
        
        main > * {
          margin-bottom: 50px;
        }
		
		footer [role=group] {
			max-width: 100%;
			overflow: auto;
		}
      ]]>
			</style>
			<script>
				<![CDATA[
        function filtersToggle() {
          let toggler = event.srcElement;
          let r = document.querySelector(':root');
          let rs = getComputedStyle(r);
          let current_footer_height = rs.getPropertyValue('--footer-height');
          if (parseInt(current_footer_height)) {
            xo.session.footer_height = current_footer_height;
            r.style.setProperty('--footer-height', '0px');
          } else {
            r.style.setProperty('--footer-height', xo.session.footer_height);
          }
        }]]>
			</script>
			<xo-listener attribute="state:current_date_er"/>
			<xo-listener node="//security/access"/>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="text()"></xsl:template>

	<xsl:key name="filters" match="/model/divisiones/division/@nom" use="'div'"/>
	<xsl:key name="filters" match="/model/razones_sociales/razon_social/@nom" use="'rs'"/>
	<xsl:key name="filters" match="/model/unidades_negocio/unidad_negocio/@nom" use="'un'"/>

	<xsl:key name="filters" match="/model/estaciones/estacion/@nom" use="'rs'"/>
	<xsl:key name="filters" match="/model/productos/producto/@nom" use="'un'"/>

	<xsl:key name="unidad_negocios" match="carteras/*/@un" use="."/>
	<xsl:key name="unidad_negocios" match="indicadores/*/@un" use="."/>
	<xsl:key name="unidad_negocios" match="polizas/*/@un" use="."/>
	<xsl:key name="unidad_negocios" match="compras/*/@un" use="."/>
	<xsl:key name="unidad_negocios" match="ventas/*/@un" use="."/>
	<xsl:key name="division" match="division[@state:checked]/@id" use="."/>
	<xsl:key name="division" match="carteras/*/@div" use="."/>
	<xsl:key name="division" match="indicadores/*/@div" use="."/>
	<xsl:key name="division" match="polizas/*/@div" use="."/>
	<xsl:key name="division" match="compras/*/@div" use="."/>
	<xsl:key name="division" match="ventas/*/@div" use="."/>

	<xsl:key name="unidad_negocios" match="carteras/@un" use="."/>
	<xsl:key name="unidad_negocios" match="indicadores/@un" use="."/>
	<xsl:key name="unidad_negocios" match="polizas/@un" use="."/>
	<xsl:key name="unidad_negocios" match="compras/@un" use="."/>
	<xsl:key name="unidad_negocios" match="ventas/@un" use="."/>
	<xsl:key name="division" match="carteras/@div" use="."/>
	<xsl:key name="division" match="indicadores/@div" use="."/>
	<xsl:key name="division" match="polizas/@div" use="."/>
	<xsl:key name="division" match="compras/@div" use="."/>
	<xsl:key name="division" match="ventas/@div" use="."/>

	<xsl:key name="changed" match="@initial:*" use="concat(../@xo:id,'::',local-name())"/>
	<xsl:template match="*">
		<style>
			<![CDATA[
			#offcanvasSelection { height: 150px; }
			]]>
		</style>
		<div class="offcanvas offcanvas-bottom" tabindex="-1" id="offcanvasSelection" aria-labelledby="offcanvasSelectionLabel" data-bs-scroll="true" data-bs-backdrop="false">
			<div class="offcanvas-body small" xo-source="active" xo-stylesheet="page_controls.seleccion.xslt">
			</div>
		</div>
	</xsl:template>

	<xsl:template mode="aria-label-attribute" match="*|@*">
		<xsl:attribute name="aria-label">
			<xsl:value-of select="name()"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="aria-label-attribute" match="*[@nom]">
		<xsl:attribute name="aria-label">
			<xsl:value-of select="@nom"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="button-group" match="*|@*">
		<xsl:param name="divisiones" select="4"></xsl:param>
		<xsl:param name="mantenibles" select="4"></xsl:param>
		<xsl:param name="items" select="ref-expected"/>
		<xsl:variable name="element" select="ancestor-or-self::*[1]"/>
		<xsl:variable name="unique" select="not($element/preceding-sibling::*|$element/following-sibling::*|$element/preceding-sibling::comment()|$element/following-sibling::comment())"/>
		<xsl:variable name="active" select="$element/@state:checked='true' or $unique"/>
		<div role="group">
			<xsl:apply-templates mode="aria-label-attribute" select="."/>
			<!--<xsl:attribute name="class">
				<xsl:text>btn-group btn-group-sm</xsl:text>
				<xsl:if test="//unidades_negocio[*[2]]">
					<xsl:text/> col-<xsl:value-of select="ceiling(6 div $divisiones) - count($mantenibles) * 2"/><xsl:text/>
				</xsl:if>
			</xsl:attribute>-->
			<xsl:variable name="id" select="@id"/>
			<style>
				:root { --footer-height: 105px; }
			</style>
			<fieldset style="min-width: 150px; width: max-content;">
				<legend style="white-space: nowrap;" xo-scope="{@xo:id}" xo-slot="state:checked">
					<xsl:if test="not($unique)">
						<xsl:attribute name="onclick">scope.toggle('true')</xsl:attribute>
					</xsl:if>
					<xsl:variable name="style">
						<xsl:if test="$active">
							<xsl:text>active</xsl:text>
						</xsl:if>
					</xsl:variable>
					<!--<button type="button" class="btn btn-outline-secondary {$style}" xo-scope="{@xo:id}" xo-slot="state:checked" onclick="scope.parentNode.$$('../*/@state:checked|../../razones_sociales/*/@state:checked').remove(); scope.set('true');">-->
					<xsl:choose>
						<xsl:when test="$active">
							<!--<xsl:attribute name="onclick">scope.remove()</xsl:attribute>-->
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-x-square" viewBox="0 0 16 16" style="margin-right: 5pt">
								<xsl:choose>
									<xsl:when test="not($unique)">
										<xsl:attribute name="onclick">scope.remove(); event.stopPropagation(); return false</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="disabled"></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
								<path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
							</svg>
						</xsl:when>
						<xsl:otherwise>
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-square" viewBox="0 0 16 16" style="margin-right: 5pt">
								<xsl:if test="not($unique)">
									<xsl:attribute name="onclick">scope.set('true'); event.stopPropagation(); return false;</xsl:attribute>
								</xsl:if>

								<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
							</svg>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="@nom"/>
					<!--</button>-->
				</legend>
				<xsl:apply-templates mode="button" select="$items[.=$id]/.."/>
			</fieldset>
		</div>
	</xsl:template>

	<xsl:key name="filters" match="model/estaciones" use="'*'"/>
	<xsl:key name="filters" match="model/estaciones/estacion/@nom" use="name(../..)"/>
	<xsl:key name="filters" match="model/estaciones/estacion/@nom" use="concat(name(../..),'::',.)"/>

	<xsl:template mode="filters" match="*">
		<xsl:variable name="items" select="key('filters',name())"/>
		<div class="btn-group btn-group-sm col-12" role="group" aria-label="{name()}" style="margin-left:1rem;">
			<style>
				:root { --footer-height: <xsl:value-of select="105 + 40 * floor((count($items) div 10))"/>px; }
			</style>
			<fieldset>
				<legend>
					<xsl:value-of select="name()"/>
				</legend>
				<xsl:apply-templates mode="button" select="$items"/>
			</fieldset>
		</div>
	</xsl:template>

	<xsl:template mode="filters" match="actividades">
		<xsl:variable name="items" select="key('filters',name())[count(.|key('filters',concat(name(current()),'::',.))[1])=1]"/>
		<div class="btn-group btn-group-sm col-12" role="group" aria-label="Segmentos" style="margin-left:1rem;">
			<style>
				:root { --footer-height: <xsl:value-of select="105 + 40 * floor((count($items) div 10))"/>px; }
			</style>
			<fieldset>
				<legend>
					<xsl:value-of select="name()"/>
				</legend>
				<xsl:apply-templates mode="button" select="$items"/>
			</fieldset>
		</div>
	</xsl:template>

	<xsl:template match="model">
		<xsl:variable name="mantenibles" select="mantenibles[*]"/>
		<style>
			<xsl:if test="$mantenibles">
				:root { --footer-height: 60px; }
			</xsl:if>
			<![CDATA[
			#offcanvasSelection { height: 150px; }
			]]>
		</style>
		<div class="offcanvas offcanvas-bottom" tabindex="-1" id="offcanvasSelection" aria-labelledby="offcanvasSelectionLabel" data-bs-scroll="true" data-bs-backdrop="false">
			<div class="offcanvas-body small" xo-source="active" xo-stylesheet="page_controls.seleccion.xslt">
			</div>
		</div>

		<div class="filters-toggle toggle-filters" onclick="this.classList.toggle('closed'); filtersToggle();">
			<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-funnel" viewBox="0 0 16 16">
				<path d="M1.5 1.5A.5.5 0 0 1 2 1h12a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-.128.334L10 8.692V13.5a.5.5 0 0 1-.342.474l-3 1A.5.5 0 0 1 6 14.5V8.692L1.628 3.834A.5.5 0 0 1 1.5 3.5v-2zm1 .5v1.308l4.372 4.858A.5.5 0 0 1 7 8.5v5.306l2-.666V8.5a.5.5 0 0 1 .128-.334L13.5 3.308V2h-11z"/>
			</svg>
		</div>
		<xsl:apply-templates mode="filters" select="key('filters','*')"/>
		<xsl:variable name="divs" select="key('filters','div')"/>
		<xsl:variable name="rss" select="key('filters','rs')"/>
		<xsl:choose>
			<xsl:when test="$divs">
				<xsl:apply-templates mode="button-group" select="$divs/parent::*">
					<xsl:with-param name="items" select="key('filters','rs')/../@div"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="button-group" select="$rss/parent::*"/>
			</xsl:otherwise>
		</xsl:choose>


		<xsl:if test="unidades_negocio[*[2]]">
			<xsl:comment>
				<xsl:value-of select="floor(count(unidades_negocio/unidad_negocio) div 5)"/>
			</xsl:comment>
			<style>
				:root { --footer-height: <xsl:value-of select="105 + 40 * floor((count(unidades_negocio/unidad_negocio) div 5))"/>px; }
			</style>
			<div class="btn-group btn-group-sm col-6" role="group" aria-label="Segmentos" style="margin-left:1rem;">
				<fieldset>
					<legend>Segmentos</legend>
					<xsl:apply-templates mode="button" select="unidades_negocio/unidad_negocio"/>
				</fieldset>
			</div>
		</xsl:if>

		<xsl:for-each select="$mantenibles">
			<button class="btn btn-primary" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasMantenibles" aria-controls="offcanvasBottom" style="margin-left:5rem;">Mantenibles</button>
		</xsl:for-each>
		<xsl:if test="//@state:dirty">
			<style>
				:root { --footer-height: 74px; }
			</style>
			<ul class="col-12 nav justify-content-end list-unstyled d-flex">
				<li class="ms-3" xo-scope="{@xo:id}">
					<button class="btn btn-primary" type="button" onclick="submit(scope)" xo-scope="{ancestor-or-self::*[1]/@xo:id}">Guardar</button>
				</li>
			</ul>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
