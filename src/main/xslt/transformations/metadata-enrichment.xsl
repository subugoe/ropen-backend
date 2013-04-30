<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                version="1.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Sep 29, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
    <!-- TODO:
            
    --><xsl:include href="gettyLib.xsl"/>
   <xsl:include href="cerlLib.xsl"/>
   <xsl:include href="archaeo18Services.xsl"/>
   <xsl:preserve-space elements="*"/>
   <xsl:param name="guessDates" select="true()"/>
   <xsl:output indent="no" method="xml"/>
   <xsl:template match="/">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="TEI:placeName">
      <xsl:copy>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:apply-templates/>
         <xsl:variable name="addNames">
            <xsl:call-template name="getPlaceVariants">
               <xsl:with-param name="node">
                  <xsl:call-template name="queryGettyRef">
                     <xsl:with-param name="ref" select="@ref"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="display-attribute-name" select="'type'"/>
               <xsl:with-param name="display-attribute-value" select="'display'"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:if test="string($addNames) != ''">
            <xsl:comment>
               <xsl:text>//Start of metadata enrichment</xsl:text>
            </xsl:comment>
            <xsl:copy-of select="$addNames"/>
            <xsl:comment>
               <xsl:text>//End of metadata enrichment</xsl:text>
            </xsl:comment>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:persName">
      <xsl:copy>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:variable name="cerlEntry">
            <xsl:call-template name="queryCerlCTAS">
               <xsl:with-param name="id">
                  <xsl:call-template name="extractCerlId">
                     <xsl:with-param name="ref" select="@ref"/>
                  </xsl:call-template>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="pnd">
            <xsl:call-template name="getPND">
               <xsl:with-param name="node" select="$cerlEntry"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:if test="string-length($pnd) &gt; 1">
            <xsl:attribute name="key">
               <xsl:value-of select="concat('#PND:', $pnd)"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
         <xsl:variable name="addNames">
            <xsl:call-template name="getPersVariants">
               <xsl:with-param name="node" select="$cerlEntry"/>
               <xsl:with-param name="display-attribute-name" select="'type'"/>
               <xsl:with-param name="display-attribute-value" select="'display'"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:if test="string($addNames) != ''">
            <xsl:comment>
               <xsl:text>//Start of metadata enrichment</xsl:text>
            </xsl:comment>
            <xsl:copy-of select="$addNames"/>
            <xsl:comment>
               <xsl:text>//End of metadata enrichment</xsl:text>
            </xsl:comment>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:date">
      <xsl:copy>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:if test="not(@when)">
            <xsl:variable name="computedDate">
               <xsl:call-template name="parseDate">
                  <xsl:with-param name="date" select="./text()"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$computedDate != '' and string($guessDates) = string(true())">
               <xsl:attribute name="when">
                  <xsl:value-of select="$computedDate"/>
               </xsl:attribute>
            </xsl:if>
         </xsl:if>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="*" priority="-1">
      <xsl:copy>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:apply-templates select="node()"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
