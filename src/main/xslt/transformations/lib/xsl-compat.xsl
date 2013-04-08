<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://www.exslt.org/strings" xmlns:url="http://whatever/java/java.net.URLEncoder" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd" version="2.0"><xd:doc scope="stylesheet"><xd:desc><xd:p><xd:b>Created on:</xd:b> Feb 19, 2012</xd:p><xd:p><xd:b>Author:</xd:b> cmahnke</xd:p><xd:p/></xd:desc></xd:doc>
    <!-- Internal variable to check if certain extensions are available --><xsl:variable name="xslVersion"><xsl:choose><xsl:when test="number(substring(system-property('xsl:version'), 1, 1)) &gt; 1"><xsl:value-of select="2"/></xsl:when><xsl:otherwise><xsl:value-of select="1"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="useEXSL"><xsl:choose><xsl:when test="$xslVersion &gt; 1"><xsl:value-of select="false()"/></xsl:when><xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="true()"/></xsl:when><xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:template name="checkEXSL"><xsl:if test="$useEXSL = string(false()) and $xslVersion = 1"><xsl:message terminate="yes">XSLT Processor is not capable of using EXSL or not version
                2.0</xsl:message></xsl:if></xsl:template>
    <!--
ISO-8859-1 based URL-encoding demo Written by Mike J. Brown, mike@skew.org. Updated 2002-05-20. No license; use freely, but credit me if reproducing in print. Also see http://skew.org/xml/misc/URI-i18n/ for a discussion of non-ASCII characters in URIs.
-->
    <!--
The string to URL-encode. Note: By "iso-string" we mean a Unicode string where all the characters happen to fall in the ASCII and ISO-8859-1 ranges (32-126 and 160-255)
-->

    <!--
Characters we'll support. We could add control chars 0-31 and 127-159, but we won't.
--><xsl:variable name="ascii">
        !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
    </xsl:variable><xsl:variable name="latin1">
        ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ
    </xsl:variable>
    <!-- Characters that usually don't need to be escaped --><xsl:variable name="safe">
        !'()*-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~
    </xsl:variable><xsl:variable name="hex">0123456789ABCDEF</xsl:variable><xsl:template name="encode"><xsl:param name="str"/><xsl:choose><xsl:when test="starts-with(system-property('xsl:version'), '2')"><xsl:call-template name="encode-uri"><xsl:with-param name="str" select="$str"/></xsl:call-template></xsl:when><xsl:when test="starts-with(system-property('xsl:version'), '1')"><xsl:call-template name="url-encode"><xsl:with-param name="str" select="$str"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:message terminate="yes">
                    Wrong XSLT Version!
                </xsl:message></xsl:otherwise></xsl:choose></xsl:template>


    <!-- This is for XSLT 2.0 --><xsl:template name="encode-uri"><xsl:param name="str"/><xsl:value-of select="encode-for-uri(string-join($str, ''))"/></xsl:template>

    <!-- This is for XSLT 1.0 --><xsl:template name="url-encode"><xsl:param name="str"/><xsl:if test="$str"><xsl:variable name="first-char" select="substring($str,1,1)"/><xsl:choose><xsl:when test="contains($safe,$first-char)"><xsl:value-of select="$first-char"/></xsl:when><xsl:otherwise><xsl:variable name="codepoint"><xsl:choose><xsl:when test="contains($ascii,$first-char)"><xsl:value-of select="string-length(substring-before($ascii,$first-char)) + 32"/></xsl:when><xsl:when test="contains($latin1,$first-char)"><xsl:value-of select="string-length(substring-before($latin1,$first-char)) + 160"/></xsl:when><xsl:otherwise><xsl:message terminate="no">
                                    Warning: string contains a character that is out of range! Substituting "?".
                                </xsl:message><xsl:text>63</xsl:text></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="hex-digit1" select="substring($hex,floor($codepoint div 16) + 1,1)"/><xsl:variable name="hex-digit2" select="substring($hex,$codepoint mod 16 + 1,1)"/><xsl:value-of select="concat('%',$hex-digit1,$hex-digit2)"/></xsl:otherwise></xsl:choose><xsl:if test="string-length($str) &gt; 1"><xsl:call-template name="url-encode"><xsl:with-param name="str" select="substring($str,2)"/></xsl:call-template></xsl:if></xsl:if></xsl:template>
    <!--
    <xsl:template name="url-encode-old">
        <xsl:param name="str"/>
        <xsl:choose>
            <!- - Saxon - ->
            <xsl:when test="function-available(url:encode)">
                <xsl:value-of select="url:encode($str)"/>
            </xsl:when>
            <!- - EXSL - ->
            <xsl:when test="function-available(str:encode-uri)">
                <xsl:value-of select="str:encode-uri($str)"/>
            </xsl:when>
            <!- - XSLT 2.0 - ->
            <xsl:when test="function-available(encode-for-uri)">
                <xsl:value-of select="encode-for-uri($str)"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    --></xsl:stylesheet>