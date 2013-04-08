<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd" version="2.0"><xd:doc scope="stylesheet"><xd:desc><xd:p><xd:b>Created on:</xd:b> Feb 3, 2012</xd:p><xd:p><xd:b>Author:</xd:b> cmahnke</xd:p><xd:p/></xd:desc></xd:doc><xsl:include href="./lib/xsl-compat.xsl"/><xsl:param name="dateService" select="'http://134.76.21.92:8080/exist/rest/db/archaeo18/queries/services/parseDate.xq'"/><xsl:param name="dateQueryPrefix" select="'?date='"/>
    <!-- This is just for testing purposes -->
    <!-- 
    <xsl:template match="/">
        <xsl:variable name="date" select="'Sommer 1785'"> </xsl:variable>
        <xsl:call-template name="parseDate">
            <xsl:with-param name="date" select="$date"> </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
     --><xsl:template name="parseDate"><xsl:param name="date"/><xsl:variable name="encoded-date"><xsl:call-template name="encode"><xsl:with-param name="str" select="$date"/></xsl:call-template></xsl:variable><xsl:variable name="query-url" select="concat($dateService, $dateQueryPrefix, $encoded-date)"/><xsl:message>
            Quering URL <xsl:value-of select="$query-url"/></xsl:message><xsl:variable name="result" select="document($query-url)"/><xsl:value-of select="$result//xhtml:span[@computedDate]"/></xsl:template></xsl:stylesheet>