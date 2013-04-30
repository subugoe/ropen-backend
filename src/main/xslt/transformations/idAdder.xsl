<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a18enrich="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs xd"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Apr 5, 2012</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="idEndpoint">
      <xsl:value-of select="'http://134.76.21.92:8080/exist/rest/db/archaeo18/queries/services/lookupID.xq?query='"/>
   </xsl:param>
   <xsl:template match="/">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="*">
      <xsl:copy>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:apply-templates select="node()"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:persName|TEI:term|TEI:placeName">
      <xsl:copy>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
               <xsl:value-of select="."/>
            </xsl:attribute>
         </xsl:for-each>
         <xsl:choose>
            <xsl:when test="not(@ref)">
                    <!-- Try to remove line breaks --><xsl:variable name="query" select="replace(string (.), '-\s+', '')"/>
               <xsl:variable name="url"
                             select="concat($idEndpoint, $query, '&amp;type=', local-name(.))"/>
               <xsl:variable name="id">
                  <xsl:value-of select="document($url)//a18enrich:id"/>
               </xsl:variable>
               <xsl:if test="$id != ''">
                  <xsl:attribute name="ref">
                     <xsl:value-of select="$id"/>
                  </xsl:attribute>
                  <xsl:attribute name="enriched"
                                 namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment"
                                 select="'true'"/>
               </xsl:if>
               <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
