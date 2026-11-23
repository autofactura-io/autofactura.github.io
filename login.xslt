<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xo="http://panax.io/xover"
    xmlns:session="http://panax.io/session"
    xmlns:meta="http://panax.io/site/meta"
    xmlns:js="http://panax.io/languages/javascript"
    xmlns:login="http://widgets.panaxbi.com/login"
    exclude-result-prefixes="session login js">
    <xsl:import href="widgets/login.xslt"/>
    <xsl:param name="session:login_error"/>
    <xsl:template match="*" mode="login:widget" priority="10">
        <section id="autofactura-login-view" class="login autofactura-login">
            <style><![CDATA[
.login.autofactura-login { width: 100%; max-width: none; margin: 0; min-height: 100dvh; padding: clamp(1rem,5vh,3rem) 1rem; display: grid; justify-items: center; align-items: end; background: #eef3f8 url(assets/background.jpg) center / cover no-repeat; }
.autofactura-login .login-card { width: min(100%,23rem); padding: clamp(1.25rem,4vw,2rem); background: #fff; color: #263b4e; border-radius: .75rem; box-shadow: 0 .65rem 2rem rgba(25,56,85,.16); }
.autofactura-login .login-logo { width: min(100%,15rem); height: auto; }
.autofactura-login .google-login { display: grid; justify-items: center; margin-top: 1rem; }
@media (max-height: 42rem) { .login.autofactura-login { align-items: center; } }
            ]]></style>
                    <script src="widgets/login.js" fetchpriority="high"/>
                    <div class="login-card">
                        <form onsubmit="event.preventDefault(); iniciarSesionAutofactura(this);">
                        <img src="assets/logotype.png" alt="Autofactura" class="login-logo d-block mx-auto mb-4"/>
                        <h1 class="h4 text-center mb-3">Bienvenido</h1>
                        <label for="username" class="form-label">Usuario</label>
                        <input id="username" name="UserName" type="text" class="form-control mb-3" autocomplete="username" required="required" value="{$session:user_login}"/>
                        <label for="password" class="form-label">Contraseña</label>
                        <input id="password" name="Password" type="password" class="form-control mb-3" autocomplete="current-password" required="required"/>
                        <p role="alert" class="text-danger small" aria-live="polite"><xsl:value-of select="$session:login_error"/></p>
                        <button type="submit" class="btn btn-primary w-100">Ingresar</button>
                        </form>
                        <xsl:if test="$meta:google-signin-client_id!=''">
                            <div class="google-login">
                                <xsl:choose>
                                    <xsl:when test="$js:secure='true'">
                                        <div xo-static="self::*">
                                            <div id="g_id_onload" data-client_id="{$meta:google-signin-client_id}" data-callback="onGoogleLogin" data-auto_prompt="false"/>
                                            <div class="g_id_signin" data-type="standard" data-size="large" data-theme="outline" data-text="continue_with" data-logo_alignment="left"/>
                                        </div>
                                        <script src="https://accounts.google.com/gsi/client" async="async" defer="defer"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p class="small text-muted text-center mb-0">El acceso con Google requiere una conexión HTTPS segura.</p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </xsl:if>
                    </div>
        </section>
    </xsl:template>
</xsl:stylesheet>
