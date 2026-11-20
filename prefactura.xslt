<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:template match="/">
<section id="page-content">
<section id="prefactura" xo-store="#facturas" class="container-fluid py-3">
  <style>
    #prefactura .pf-toolbar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:16px}
    #prefactura .pf-toolbar p{margin:0;flex:1}#prefactura .pf-fields{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px}
    #prefactura label{display:flex;flex-direction:column;font-size:13px;gap:5px}#prefactura input,#prefactura textarea{width:100%;border:1px solid #cbd5e1;border-radius:5px;padding:7px;background:white;color:#111}
    #prefactura details{background:white;border:1px solid #dce2e8;border-radius:6px;padding:14px;margin-bottom:14px}#prefactura summary{font-weight:600;cursor:pointer;margin-bottom:10px}
    #prefactura .pf-concepts{max-height:360px;overflow:auto}#prefactura table{font-size:12px;min-width:800px}#prefactura table input{min-width:85px}
    #prefactura iframe{width:100%;height:85vh;border:1px solid #cbd5e1;background:white;border-radius:6px}#prefactura [hidden]{display:none!important}
  </style>
  <div data-empty="" class="alert alert-info">Selecciona tickets en Factura Global y pulsa «Generar pre-factura». <a href="#factura_global">Ir a Factura Global</a></div>
  <div data-content="" hidden="hidden">
    <header class="pf-toolbar"><a href="#factura_global" class="btn btn-outline-secondary">Volver a tickets</a><p data-summary=""></p><button type="button" data-preview="" class="btn btn-outline-primary">Actualizar vista previa</button><button type="button" data-print="" class="btn btn-primary">Imprimir / guardar PDF</button></header>
    <details open="open"><summary>Datos de la pre-factura</summary><div class="pf-fields" data-fields=""></div></details>
    <details><summary>Revisar cantidades, unidades y claves SAT</summary><p class="text-muted small">Los importes e impuestos se conservan de los tickets. Cambiar la cantidad modifica el valor unitario, no el importe.</p><div class="pf-concepts"><table class="table"><thead><tr><th>Producto</th><th>Cantidad</th><th>Unidad</th><th>Clave unidad</th><th>Clave SAT</th><th>Importe</th></tr></thead><tbody data-concepts=""></tbody></table></div></details>
    <p data-warning="" class="alert alert-warning small"></p>
    <p data-print-status="" role="status" class="small text-muted"></p>
    <iframe title="Vista previa de la pre-factura"></iframe>
  </div>
  <script>autofactura.prefactura.mount(document.getElementById('prefactura'));</script>
</section>
</section>
  </xsl:template>
</xsl:stylesheet>
