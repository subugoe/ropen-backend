<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Apr 19, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
         <xd:p>Adds Numbers to page breaks (&lt;pb/&gt;) and line breaks (&lt;lb/&gt;). Also adds
                IDs to structural elements (&lt;div/&gt;, &lt;p/&gt;, &lt;note/&gt;)</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="/">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="TEI:pb">
      <xsl:copy>
         <xsl:attribute name="id">
            <xsl:value-of select="generate-id()"/>
         </xsl:attribute>
         <xsl:attribute name="n">
            <xsl:value-of select="count(preceding::TEI:pb) + 1"/>
         </xsl:attribute>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:div|TEI:p|TEI:note">
      <xsl:copy>
         <xsl:attribute name="id">
            <xsl:value-of select="generate-id()"/>
         </xsl:attribute>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:apply-templates select="node()"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:lb">
      <xsl:copy>
         <xsl:attribute name="id">
            <xsl:value-of select="generate-id()"/>
         </xsl:attribute>
         <xsl:attribute name="n">
            <xsl:choose>
               <xsl:when test="count(preceding::TEI:pb) &lt; 1">
                  <xsl:value-of select="count(preceding::TEI:lb)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="count(preceding::TEI:pb[1]/following::TEI:lb) - count(following::TEI:lb)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
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
