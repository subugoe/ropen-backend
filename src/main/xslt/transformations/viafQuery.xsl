<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                version="1.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Sep 30, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
    <!-- 
    Documentation for Viaf
    http://www.oclc.org/developer/documentation/virtual-international-authority-file-viaf/request-types
    Example for Christian Gottlob Heyne
    http://viaf.org/processed/DNB|11855073X
    --><xsl:variable name="viafEndpoint">http://viaf.org/search?query=</xsl:variable>
   <xsl:variable name="viafSuffix">&amp;httpAccept=text/xml</xsl:variable>
   <xsl:variable name="viafPNDPrefix">http://viaf.org/processed/DNB|</xsl:variable>
   <xsl:template name="queryViaf">
      <xsl:param name="id"/>
      <xsl:variable name="viafEntry" select="document(concat($viafPNDPrefix, $id))"/>
      <xsl:copy-of select="$viafEntry"/>
   </xsl:template>
</xsl:stylesheet>
