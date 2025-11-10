<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:js="http://panax.io/languages/javascript"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
exclude-result-prefixes="#default session sitemap shell"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:template match="text()"/>
	<xsl:param name="session:user_login"/>
	<xsl:param name="session:debug">false</xsl:param>
	<xsl:param name="js:cache_name">xover.session.cache_name.split('_').pop()</xsl:param>
	<xsl:key name="expanded" match="*[@state:expanded='true']" use="true()"/>

	<xsl:template match="*">
		<span>
			<style>
				<![CDATA[
.avatar {
    margin-top: -15px;
    margin-bottom: -15px;
    width: 40px;
    height: 40px;
}
			]]>
			</style>
			<ul class="navbar-nav ml-auto">
				<!--Idiomas Search-->
				<li class="nav-item dropdown no-arrow d-sm-none">
					<a class="nav-link dropdown-toggle" href="#" id="searchDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
						<i class="fas fa-globe"></i>
					</a>

					<!-- Dropdown - Search -->
					<div class="dropdown-menu dropdown-menu-right p-3 shadow animated--grow-in" aria-labelledby="searchdropdown">
						<form class="form-inline mr-auto w-100 navbar-search">
							<div class="input-group">
								<input type="text" class="form-control bg-light border-0 small" placeholder="search for..." aria-label="search" aria-describedby="basic-addon2"/>
								<div class="input-group-append">
									<button class="btn btn-primary" type="button">
										<i class="fas fa-globe"></i>
									</button>
								</div>
							</div>
						</form>
					</div>
				</li>

				<px-to-excel/>
				<px-printer/>

				<!-- Nav Item - Notifications -->
				<div class="dropdown">
					<a class="btn dropdown-toggle" href="#" role="button" id="dropdownMenuLink" data-bs-toggle="dropdown" aria-expanded="false">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-bell" viewBox="0 0 16 16">
							<path d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zM8 1.918l-.797.161A4.002 4.002 0 0 0 4 6c0 .628-.134 2.197-.459 3.742-.16.767-.376 1.566-.663 2.258h10.244c-.287-.692-.502-1.49-.663-2.258C12.134 8.197 12 6.628 12 6a4.002 4.002 0 0 0-3.203-3.92L8 1.917zM14.22 12c.223.447.481.801.78 1H1c.299-.199.557-.553.78-1C2.68 10.2 3 6.88 3 6c0-2.42 1.72-4.44 4.005-4.901a1 1 0 1 1 1.99 0A5.002 5.002 0 0 1 13 6c0 .88.32 4.2 1.22 6z"/>
						</svg>
					</a>
					<xsl:variable name="notifications" select="notifications/item"/>
					<!--<xsl:if test="$notifications">
						-->
					<!-- Counter - Notifications -->
					<!--
						<span class="badge badge-danger badge-counter">
							<xsl:value-of select="count($notifications)"/>
						</span>
					</xsl:if>-->

					<ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuLink">
						<xsl:for-each select="$notifications">
							<li>
								<a class="dropdown-item" href="#">
									<xsl:value-of select="text()"/>
								</a>
							</li>
						</xsl:for-each>
						<li>
							<hr class="dropdown-divider"/>
						</li>
						<li>
							<a class="dropdown-item" href="#">Mostrar todas las notificaciones</a>
						</li>
					</ul>
				</div>

				<div class="topbar-divider d-none d-sm-block"></div>
				<!-- Nav Item - Person -->
				<div class="dropdown">
					<a class="btn dropdown-toggle" href="#" role="button" id="dropdownMenuLink" data-bs-toggle="dropdown" aria-expanded="false">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-fill" viewBox="0 0 16 16">
							<path d="M3 14s-1 0-1-1 1-4 6-4 6 3 6 4-1 1-1 1H3zm5-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/>
						</svg>&#160;&#160;<xsl:value-of select="$session:user_login"/>
					</a>
					<ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuLink">
						<li>
							<a class="dropdown-item disabled" href="#">
								<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-badge-fill" viewBox="0 0 16 16">
									<path d="M2 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2zm4.5 0a.5.5 0 0 0 0 1h3a.5.5 0 0 0 0-1h-3zM8 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm5 2.755C12.146 12.825 10.623 12 8 12s-4.146.826-5 1.755V14a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1v-.245z"/>
								</svg>
								<label>Perfil</label>
							</a>
						</li>
						<li>
							<hr class="dropdown-divider"/>
						</li>
						<li onclick="xo.session.logout()">
							<a class="dropdown-item" href="#">
								<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-door-open-fill" viewBox="0 0 16 16">
									<path d="M1.5 15a.5.5 0 0 0 0 1h13a.5.5 0 0 0 0-1H13V2.5A1.5 1.5 0 0 0 11.5 1H11V.5a.5.5 0 0 0-.57-.495l-7 1A.5.5 0 0 0 3 1.5V15H1.5zM11 2h.5a.5.5 0 0 1 .5.5V15h-1V2zm-2.5 8c-.276 0-.5-.448-.5-1s.224-1 .5-1 .5.448.5 1-.224 1-.5 1z"/>
								</svg>
								<label>Salir</label>
							</a>
						</li>
					</ul>
				</div>
			</ul>
		</span>
	</xsl:template>

</xsl:stylesheet>
