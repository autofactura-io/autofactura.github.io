<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cfdi="http://www.sat.gob.mx/cfd/4"
    xmlns:factura="http://panax.io/widget/factura"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="cfdi factura">
    <xsl:import href="widgets/cfdi/cfdi.xslt"/>
    <xsl:template match="/">
        <dialog class="xover-component descarga-cfdi-visor" aria-label="Visor de CFDI"
                style="width:min(96vw,1000px);max-height:92vh;overflow:auto;margin:auto" onclose="this.remove()">
            <form method="dialog" style="display:flex;justify-content:flex-end">
                <button type="submit" class="btn btn-outline-secondary">Cerrar</button>
            </form>
            <xsl:apply-templates select="//*[local-name()='Comprobante' and namespace-uri()='http://www.sat.gob.mx/cfd/4'][1]" mode="factura:widget"/>
        </dialog>
    </xsl:template>
    <xsl:template match="*" mode="cfdi:qr-code" priority="1">
        <xsl:param name="url"/>
        <div data-cfdi-qr="{$url}" aria-label="Código QR de verificación"/>
    </xsl:template>
</xsl:stylesheet>
