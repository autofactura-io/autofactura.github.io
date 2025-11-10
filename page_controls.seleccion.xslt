<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:state="http://panax.io/state"
xmlns:session="http://panax.io/session"
xmlns:env="http://panax.io/state/environment"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
	<xsl:output method="xml"
		 omit-xml-declaration="yes"
		 indent="yes"/>
	<xsl:param name="state:active"/>

	<xsl:template match="*[not(*)]|text()"/>
	<xsl:template match="/">
		<div class="offcanvas-body small">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="*">
		<div class="offcanvas-header d-flex p-0">
			<button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
			<div class="input-group justify-content-end" xo-source="seed" xo-stylesheet="page_controls.validacion.xslt"/>
		</div>
		<div class="offcanvas-body">
			<form class="d-flex" id="selection">
				<div class="input-group valor d-none">
					<span class="input-group-text">Valor:</span>
					<input name="valor" type="text" class="form-control" placeholder="Valor" aria-label="Username" aria-describedby="Valor de la selección" readonly=""/>
				</div>
				<div class="input-group formula d-none">
					<span class="input-group-text">Fórmula:</span>
					<label class="input-group-text"></label>
					<br/>
					<code style="font-size: 20pt; width: max-content;"></code>
				</div>
				<xsl:if test="//@env:store='#auxiliar_cuentas'">
					<div class="input-group detalle d-none">
						<a class="btn btn-primary" href="?value={.}#balance_operativo?@fecha_inicio={//fechas/@state:fecha_inicio}&amp;@fecha_fin={//fechas/@state:fecha_fin}" role="button">Ver comparativa</a>
					</div>
				</xsl:if>
			</form>
		</div>
	</xsl:template>
</xsl:stylesheet>
