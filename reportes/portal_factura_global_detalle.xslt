<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:state="http://panax.io/state"
    exclude-result-prefixes="state">
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    <xsl:template match="/">
        <div id="fg-ticket-full" class="shell-dialog__layout">
            <xsl:apply-templates select="model/state:ticket-detail"/>
        </div>
    </xsl:template>
    <xsl:template match="state:ticket-detail">
        <div class="shell-dialog__body p-3">
            <dl class="row small mb-3">
                <dt class="col-sm-3">Fecha</dt><dd class="col-sm-9"><xsl:value-of select="@fecha"/></dd>
                <dt class="col-sm-3">Sucursal</dt><dd class="col-sm-9"><xsl:value-of select="@sucursal"/></dd>
                <dt class="col-sm-3">Estado</dt><dd class="col-sm-9"><xsl:value-of select="@estado"/></dd>
                <xsl:if test="@receptor != ''">
                    <dt class="col-sm-3">Receptor</dt><dd class="col-sm-9"><xsl:value-of select="@receptor"/></dd>
                </xsl:if>
                <dt class="col-sm-3">Formas de pago</dt>
                <dd class="col-sm-9">
                    <xsl:choose>
                        <xsl:when test="payment">
                            <ul class="list-unstyled mb-0">
                                <xsl:for-each select="payment">
                                    <li><xsl:value-of select="@forma"/><xsl:if test="@monto != ''"><xsl:text> · </xsl:text><xsl:value-of select="@monto"/></xsl:if></li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>Sin forma de pago</xsl:otherwise>
                    </xsl:choose>
                </dd>
            </dl>
            <div class="table-responsive">
                <table class="table table-sm table-striped mb-0">
                    <thead>
                        <tr><th scope="col">Código</th><th scope="col">Producto</th><th scope="col">Cantidad</th>
                            <th scope="col" class="text-end">Subtotal</th><th scope="col" class="text-end">IVA</th>
                            <th scope="col" class="text-end">IEPS</th><th scope="col" class="text-end">Total</th></tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="item">
                            <tr>
                                <td><xsl:value-of select="@codigo"/></td>
                                <td><xsl:value-of select="@descripcion"/></td>
                                <td><xsl:value-of select="@cantidad"/><xsl:if test="@unidad != ''"><xsl:text> </xsl:text><xsl:value-of select="@unidad"/></xsl:if></td>
                                <xsl:call-template name="amounts"/>
                            </tr>
                        </xsl:for-each>
                        <xsl:if test="not(item)"><tr><td colspan="7">Sin productos registrados</td></tr></xsl:if>
                    </tbody>
                </table>
            </div>
        </div>
        <footer class="border-top px-3 py-2">
            <dl class="d-flex flex-wrap justify-content-end gap-3 small mb-0">
                <div><dt>Subtotal</dt><dd class="mb-0"><xsl:value-of select="@subtotal"/></dd></div>
                <div><dt>IVA</dt><dd class="mb-0"><xsl:value-of select="@iva"/></dd></div>
                <div><dt>IEPS</dt><dd class="mb-0"><xsl:value-of select="@ieps"/></dd></div>
                <div><dt>Total ticket</dt><dd class="fw-bold mb-0"><xsl:value-of select="@total"/></dd></div>
            </dl>
        </footer>
    </xsl:template>
    <xsl:template name="amounts">
        <td class="text-end text-nowrap"><xsl:value-of select="@subtotal"/></td>
        <td class="text-end text-nowrap"><xsl:value-of select="@iva"/></td>
        <td class="text-end text-nowrap"><xsl:value-of select="@ieps"/></td>
        <td class="text-end text-nowrap"><xsl:value-of select="@total"/></td>
    </xsl:template>
</xsl:stylesheet>
