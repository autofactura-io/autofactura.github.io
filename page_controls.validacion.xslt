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
  <xsl:param name="state:active"/>
  <xsl:param name="state:validate"/>
  <xsl:param name="state:blacklist"/>

  <xsl:template match="*[not(*)]|text()"/>
  <xsl:template match="*">
    <div class="input-group justify-content-end">
      <style>
        <![CDATA[
        .section {
          margin-left: 10px;
          margin-right: 10px;
          flex-wrap: nowrap;
          display: flex;
        }
        
        .section > button, .section > .btn-group, .section.active > span > small {
          display: none;
        }
        
        .section.active > button, .section.active > .btn-group {
          display: inline;
        }
        
        .section > span {
          cursor: pointer;
        }
        
        .section > span {
          display: inline;
        }
        
        .section.active > span {
          background: greenyellow !important;
        }
        ]]>
      </style>
      <xsl:if test="$state:blacklist='true'">
        <div class="section">
          <xsl:attribute name="class">active section</xsl:attribute>
          <span class="-ignorar input-group-text" onclick="this.parentNode.classList.toggle('active');">
            Ignorar<small>...</small>
          </span>
          <button type="button" class="btn btn-success justify-content-end" onclick="blacklist.add()">
            <xsl:text>selección</xsl:text>
          </button>
          <button type="button" class="btn btn-success dropdown-toggle dropdown-toggle-split" data-bs-toggle="dropdown" aria-expanded="false">
            <span class="visually-hidden">Toggle Dropdown</span>
          </button>
          <ul class="dropdown-menu">
            <li>
              <a class="dropdown-item" href="#" onclick="blacklist.upload()">Subir al servidor</a>
            </li>
          </ul>
        </div>
      </xsl:if>

      <xsl:if test="$state:validate='true'">
        <div class="section">
          <xsl:attribute name="class">active section</xsl:attribute>
          <span class="-cotejar input-group-text" onclick="this.parentNode.classList.toggle('active');">
            Cotejar selección<small>...</small>
          </span>
          <button type="button" class="btn btn-success" onclick="selection.cells.fix(true)" style="margin-right: 10px;">Coincide</button>
          <button type="button" class="btn btn-danger" onclick="selection.cells.fix(false)" style="margin-right: 10px;">No coincide</button>
          <div class="btn-group dropup mx-5">
            <button type="button" class="btn btn-success justify-content-end" onclick="xo.state.validate=true">
              <xsl:choose>
                <xsl:when test="$state:validate='true'">
                  <xsl:attribute name="onclick">xo.state.validate=false</xsl:attribute>
                  <xsl:text>Ocultar validación</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>Mostrar validación</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </button>
            <button type="button" class="btn btn-success dropdown-toggle dropdown-toggle-split" data-bs-toggle="dropdown" aria-expanded="false">
              <span class="visually-hidden">Toggle Dropdown</span>
            </button>
            <ul class="dropdown-menu">
              <li>
                <a class="dropdown-item" href="#" onclick="validation.download()">Descargar validaciones</a>
              </li>
              <li>
                <a class="dropdown-item" href="#" onclick="validation.upload()">Subir validaciones</a>
              </li>
            </ul>
          </div>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
</xsl:stylesheet>
