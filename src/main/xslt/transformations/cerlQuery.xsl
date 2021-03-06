<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> May 9, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
    <!-- inspired by http://www.script-tutorials.com/how-to-build-tags-cloud-using-xslt-transformation/ --><xsl:include href="cerlLib.xsl"/>
   <xsl:variable name="mode" select="'cloud'"/>
   <xsl:variable name="persCount" select="count(//TEI:persName[@ref != ''])"/>
   <xsl:variable name="maxFont">30</xsl:variable>
   <xsl:variable name="minFont">8</xsl:variable>
   <xsl:template match="/">
      <xsl:variable name="pers">
         <xsl:for-each select="//TEI:persName">
            <pers>
               <xsl:attribute name="id">
                  <xsl:value-of select="@ref"/>
               </xsl:attribute>
               <xsl:attribute name="n">
                  <xsl:value-of select="count(//TEI:persName[@ref = @ref])"/>
               </xsl:attribute>
            </pers>
         </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="max"/>
      <xsl:variable name="min"/>
      <html>
         <head>
            <title>Archeo18 Tag Cloud</title>
            <link media="screen"
                  href="css/styles.css"
                  type="text/css"
                  rel="stylesheet"/>
         </head>
         <body>
            <div class="main">
               <h1>Tags cloud via XSLT</h1>
               <xsl:apply-templates/>
            </div>
         </body>
      </html>
   </xsl:template>
   <xsl:template match="text()"/>
    <!--
    <xsl:template match="TEI:persName">
        <xsl:call-template name="queryCerlRef">
            <xsl:with-param name="ref" select="@ref"/>
        </xsl:call-template>
    </xsl:template>
    --><xsl:template match="TEI:persName">
      <xsl:variable name="ref" select="@ref"/>
      <xsl:variable name="cerlID">
         <xsl:call-template name="extractCerlId">
            <xsl:with-param name="ref" select="$ref"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$cerlID != ''">
         <xsl:if test="not(preceding::TEI:persName[@ref = $ref])">
            <xsl:variable name="occurences" select="count(//TEI:persName[@ref = $ref])"/>
            <pers>
               <name>
                  <xsl:call-template name="getName">
                     <xsl:with-param name="node">
                        <xsl:call-template name="queryCerlCTAS">
                           <xsl:with-param name="id" select="$cerlID"/>
                        </xsl:call-template>
                     </xsl:with-param>
                  </xsl:call-template>
               </name>
               <count>
                  <xsl:value-of select="$occurences"/>
               </count>
            </pers>
         </xsl:if>
      </xsl:if>
   </xsl:template>
    <!-- See http://www.dpawson.co.uk/xsl/sect2/N5121.html#d6613e190 --><xsl:template name="get-max">
      <xsl:param name="nodes"/>
      <xsl:choose>
         <xsl:when test="$nodes">
            <xsl:variable name="max-of-rest">
               <xsl:call-template name="get-max">
                  <xsl:with-param name="nodes" select="$nodes[position()!=1]"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
               <xsl:when test="nodes[1]/@mid &gt; $max-of-rest">
                  <xsl:value-of select="nodes[1]/@mid"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$max-of-rest"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="-1 div 0"/>
                <!-- minus infinity --></xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
