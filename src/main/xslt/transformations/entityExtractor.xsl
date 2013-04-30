<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs xd"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Jun 11, 2012</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="mode" select="'html'"/>
   <xsl:param name="filter" select="true()" as="xs:boolean"/>
   <xsl:param name="extract" select="'placeName, persName, term'"/>
   <xsl:strip-space elements="*"/>
   <xsl:include href="./lib/filter.xsl"/>
   <xsl:key name="ref" match="*" use="@ref"/>
   <xsl:variable name="entities" select="tokenize($extract, ',\s?')"/>
   <xsl:template match="/">
      <xsl:call-template name="create-cloud">
         <xsl:with-param name="entries">
            <xsl:apply-templates select="*"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="*">
      <xsl:variable name="node-name" select="local-name(.)"/>
      <xsl:choose>
         <xsl:when test="index-of($entities, $node-name)">
            <xsl:copy>
               <xsl:for-each select="@*">
                  <xsl:attribute name="{name(.)}" select="."/>
               </xsl:for-each>
               <xsl:apply-templates mode="copy"/>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="@*|node()" mode="copy">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="text()"/>
   <xsl:template match="TEI:addName|comment()" mode="copy">
      <xsl:choose>
         <xsl:when test="@type = 'display'">
                <!-- TODO: Do nothing for now --></xsl:when>
         <xsl:when test="$filter = true()"/>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="create-cloud">
      <xsl:param name="entries"/>
      <tags>
         <xsl:for-each select="distinct-values($entries/*/@ref)">
                <!-- 
               <xsl:sort select="count($entries/*[@ref = $ref])"></xsl:sort>
               --><xsl:variable name="ref" select="."/>
            <xsl:variable name="count" select="count($entries/*[@ref = $ref])"/>
            <xsl:variable name="name">
               <xsl:choose>
                  <xsl:when test="$entries/*[@ref = $ref]/TEI:addName[@type = 'display'][1] != ''">
                     <xsl:value-of select="$entries/*[@ref = $ref]/TEI:addName[@type = 'display'][1]"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$entries/*[@ref = $ref][1]"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="link"/>
            <xsl:variable name="facet"
                          select="concat(lower-case('TEI'), ':', local-name($entries/*[@ref = $ref][1]))"/>
            <tag>
               <tag>
                  <xsl:value-of select="$name"/>
               </tag>
               <facet>
                  <xsl:value-of select="$facet"/>
               </facet>
               <count>
                  <xsl:value-of select="$count"/>
               </count>
               <xsl:for-each select="$link">
                  <link>
                     <xsl:value-of select="."/>
                  </link>
               </xsl:for-each>
               <pages>
                  <xsl:for-each select="$entries/*[@ref = $ref]">
                     <page doc="" variant=""/>
                            <!--
                    <page doc="{archaeo18lib:get-doc-id($page)}" variant="{string(archaeo18lib:filter-elements($page, <TEI:addName/>, <exist:match/>))}">{$page/preceding::TEI:pb[1]/@n}</page>
                   --></xsl:for-each>
               </pages>
            </tag>
         </xsl:for-each>
      </tags>
   </xsl:template>
</xsl:stylesheet>
