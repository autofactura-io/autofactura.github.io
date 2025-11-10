<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:js="http://panax.io/languages/javascript"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="js">
	<xsl:output method="xml" indent="no" />
	<xsl:param name="js:icon"><![CDATA[[...document.querySelectorAll('link[type = "image/x-icon"]')].map(el => el && el.getAttribute("href"))[0]]]></xsl:param>
	<xsl:template match="node()">
		<div class="loading" onclick="this.remove()" role="alert" aria-busy="true">
			<div class="modal_content-loading">
				<div class="modal-dialog modal-dialog-centered">
					<div class="no-freeze-spinner">
						<div id="no-freeze-spinner">
							<div>
								<i class="icon" style="justify-content: center; display: flex; align-items: center;">
									<img src="{$js:icon}" class="ring_image" onerror="this.remove()"/>
									<span class="details" style="position: absolute; top: 3rem; width: 100%;">
										<progress style="display:none; width: 100%; accent-color: var(--progress-color, green);" max="100" value="0" aria-label="Loading…">0%</progress>
									</span>
								</i>
								<div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="text()|processing-instruction()|comment()"/>
</xsl:stylesheet>