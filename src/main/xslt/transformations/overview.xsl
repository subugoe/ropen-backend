<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd TEI a18" version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Jul 25, 2013</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="group-rows-param" select="false()"/>
   <xsl:param name="dupliate-pages-param" select="false()"/>
   <xsl:param name="entity-param" select="'TEI:persName'"/>
   <xsl:param name="mode-param" select="'cloud'"/>
   <xsl:param name="doc-name-param" select="''"/>
   <xsl:param name="collection-param" select="''"/>
   <xsl:variable name="groupRows" select="if ($group-rows-param castable as xs:boolean) then xs:boolean($group-rows-param) else false()" as="xs:boolean"/>
   <xsl:variable name="dupliatePages" select="if ($dupliate-pages-param castable as xs:boolean) then xs:boolean($dupliate-pages-param) else false()" as="xs:boolean"/>
   <xsl:variable name="entity" select="if ($entity-param castable as xs:string) then xs:string($entity-param) else 'TEI:persName'" as="xs:string"/>
   <xsl:variable name="mode" select="if ($mode-param castable as xs:string) then xs:string($mode-param) else 'cloud'" as="xs:string"/>
   <xsl:variable name="doc-name" select="if ($doc-name-param castable as xs:string) then xs:string($doc-name-param) else ''" as="xs:string"/>
   <xsl:variable name="collection" select="if (collection($collection-param)) then collection($collection-param) else ()" as="node()*"/>
   <xsl:output method="xml" indent="yes"/>
   <xsl:variable name="prefix" select="'tei:'"/>
   <xsl:include href="./lib/a18.xsl"/>
   <xsl:template match="/">
      <xsl:variable name="content">
         <xsl:choose>
            <xsl:when test="not(empty($collection))">
               <xsl:copy-of select="$collection"/>
            </xsl:when>
            <xsl:when test="not(empty($doc-name)) and $doc-name != ''">
               <xsl:copy-of select="doc($doc-name)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="."/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$mode = 'cloud'">
            <xsl:apply-templates select="$content" mode="cloud"/>
         </xsl:when>
         <xsl:when test="$mode = 'xhtml'">
            <xsl:apply-templates select="$content" mode="xhtml"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="$content"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tags">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="tag">
      <xsl:copy>
         <name>
            <xsl:choose>
               <xsl:when test="./pages/page[1]/TEI:*//TEI:addName[@type]/text()">
                  <xsl:value-of select="./pages/page[1]/TEI:*//TEI:addName[@type]/text()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="./pages/page[1]/*"/>
               </xsl:otherwise>
            </xsl:choose>
         </name>
         <facet>
            <xsl:value-of select="concat(/tags/@prefix, local-name(./pages/page[1]/*[1]))"/>
         </facet>
         <count>
            <xsl:value-of select="count(./pages/page)"/>
         </count>
         <xsl:for-each select="distinct-values(./pages/page[1]//*/@ref)">
            <link>
               <xsl:value-of select="a18:resolve-id(.)"/>
            </link>
         </xsl:for-each>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="pages">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="page">
      <xsl:variable name="variant">
         <xsl:apply-templates/>
      </xsl:variable>
      <xsl:copy>
         <xsl:attribute name="n">
            <xsl:choose>
               <xsl:when test="@n != ''">
                  <xsl:value-of select="@n"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'1'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
         <xsl:attribute name="variant">
            <xsl:value-of select="replace(replace($variant, '-&#xA;\s*',''), '&#xA;\s*',' ')"/>
         </xsl:attribute>
         <xsl:apply-templates select="@doc"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="@*">
      <xsl:copy/>
   </xsl:template>
   <xsl:template match="TEI:addName"/>
   <xsl:template match="TEI:persName|TEI:placeName|TEI:term|TEI:bibl">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="text()">
      <xsl:value-of select="normalize-space(.)"/>
   </xsl:template>
   <xsl:template match="//TEI:text" mode="cloud">
      <tags>
         <xsl:for-each-group select="a18:resolve-entity($entity, .)" group-by="@ref">
            <tag>
               <tag>
                  <xsl:choose>
                     <xsl:when test="current-group()[1]//TEI:addName[@type = 'display']/text()">
                        <xsl:value-of select="current-group()[1]//TEI:addName[@type = 'display']/text()"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:apply-templates select="current-group()[1]/*"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </tag>
               <facet>
                  <xsl:value-of select="concat($prefix, local-name(current-group()[1]))"/>
               </facet>
               <xsl:for-each select="distinct-values(current-group()[1]//*/@ref)">
                  <link>
                     <xsl:value-of select="a18:resolve-id(.)"/>
                  </link>
               </xsl:for-each>
               <count>
                  <xsl:value-of select="count(current-group())"/>
               </count>
               <pages>
                  <xsl:for-each select="current-group()">
                     <page>
                        <xsl:variable name="variant">
                           <xsl:apply-templates/>
                        </xsl:variable>
                        <xsl:attribute name="doc">
                           <xsl:value-of select="a18:get-document(.)"/>
                        </xsl:attribute>
                        <xsl:attribute name="n" select="a18:get-page-nr(.)"/>
                        <xsl:attribute name="variant">
                           <xsl:value-of select="replace(replace($variant, '-&#xA;\s*',''), '&#xA;\s*',' ')"/>
                        </xsl:attribute>
                     </page>
                  </xsl:for-each>
               </pages>
            </tag>
         </xsl:for-each-group>
      </tags>
   </xsl:template>
   <xsl:template match="//TEI:text" mode="xhtml">
      <xsl:variable name="description">
         <tr>
            <td>
               <span xml:lang="de">Entitätsbezeichnung</span>
               <span xml:lang="en">Entity</span>
            </td>
            <td>
               <span xml:lang="de">Handschrift</span>
               <span xml:lang="en">Manuscript</span>
            </td>
            <td>
               <span xml:lang="de">Seitenlink</span>
               <span xml:lang="en">Page link</span>
            </td>
         </tr>
      </xsl:variable>
      <html xmlns="http://www.w3.org/1999/xhtml">
         <head/>
         <body>
            <table>
               <thead>
                  <xsl:copy-of select="$description"/>
               </thead>
               <tbody>
                  <xsl:for-each-group select="a18:resolve-entity($entity, .)" group-by="@ref">
                     <xsl:variable name="link">
                        <xsl:value-of select="./link"/>
                     </xsl:variable>
                     <xsl:variable name="tag">
                        <xsl:choose>
                           <xsl:when test="current-group()[1]//TEI:addName[@type = 'display']/text()">
                              <xsl:value-of select="current-group()[1]//TEI:addName[@type = 'display']/text()"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:apply-templates select="current-group()[1]/*"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:variable>
                     <xsl:variable name="num-docs">
                        <xsl:value-of select="count(distinct-values(current-group()/@doc))"/>
                     </xsl:variable>
                     <xsl:variable name="context" select="."/>
                     <!-- TODO: add Grouping by document -->
                     <xsl:variable name="entity-cell">
                        <td>
                           <xsl:if test="$groupRows = true()">
                              <xsl:attribute name="rowspan">
                                 <xsl:value-of select="$num-docs"/>
                              </xsl:attribute>
                           </xsl:if>
                           <xsl:choose>
                              <xsl:when test="$link != ''">
                                 <a target="_blank">
                                    <xsl:attribute name="href">
                                       <xsl:value-of select="$link"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="$tag"/>
                                 </a>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:value-of select="$tag"/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </td>
                     </xsl:variable>
                     <xsl:for-each select="current-group()">
                        <xsl:variable name="doc-id">
                           <xsl:value-of select="a18:get-document(.)"/>
                        </xsl:variable>
                        <tr>
                           <xsl:if test="$groupRows != true() or ($groupRows = true() and position() = 1)">
                              <xsl:copy-of select="$entity-cell"/>
                           </xsl:if>
                           <td>
                              <xsl:value-of select="$tag"/>
                           </td>
                           <td>
                              <xsl:call-template name="page-links">
                                 <xsl:with-param name="context" select="$context"/>
                                 <xsl:with-param name="doc-id" select="$doc-id"/>
                              </xsl:call-template>
                           </td>
                        </tr>
                     </xsl:for-each>
                  </xsl:for-each-group>
               </tbody>
               <tfoot>
                  <xsl:copy-of select="$description"/>
               </tfoot>
            </table>
         </body>
      </html>
   </xsl:template>
   <xsl:template name="page-links">
      <xsl:param name="context"/>
      <xsl:param name="doc-id"/>
      <xsl:for-each select="$context/pages/page[@doc = $doc-id]">
         <!-- Check for duplicates here not(data(preceding-sibling::page/@n) = data(@n) and data(preceding-sibling::page/@doc) = data(@doc)) -->
         <xsl:if test="@n and (not(data(preceding-sibling::page/@n) = data(@n) and data(preceding-sibling::page/@doc) = data(@doc)) or $dupliatePages)">
            <a class="editionRef">
               <!--
                <xsl:attribute name="href">
                    <xsl:text>#p</xsl:text>
                    <xsl:value-of select="@n"/>
                </xsl:attribute>
                -->
               <xsl:attribute name="rel">
                  <xsl:value-of select="$doc-id"/>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="@n"/>
               </xsl:attribute>
               <xsl:if test="@variant">
                  <xsl:attribute name="title" select="a18:clear-title(@variant)"/>
               </xsl:if>
               <xsl:value-of select="@n"/>
            </a>
            <!-- This only works for one document -->
            <xsl:if test="position() != last() or not(following-sibling::page/@doc = $doc-id)">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="TEI:teiHeader" mode="#all"/>
   <xsl:function name="a18:clear-title" as="xs:string">
      <xsl:param name="variant"/>
      <!-- Remove hyphen and the line break -->
      <xsl:value-of select="replace(replace($variant, '-&#xA;\s*',''), '&#xA;\s*',' ')"/>
   </xsl:function>
   <xsl:function name="a18:get-document" as="xs:string">
      <xsl:param name="node"/>
      <xsl:choose>
         <xsl:when test="$doc-name != ''">
            <xsl:value-of select="$doc-name"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="document-uri($node)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="a18:resolve-entity" as="element()*">
      <xsl:param name="entity"/>
      <xsl:param name="nodes" as="node()*"/>
      <xsl:if test="contains($entity, ',')">
         <xsl:message terminate="yes">Only one entity is currently supported</xsl:message>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="contains($entity, 'pers')">
            <xsl:copy-of select="$nodes//TEI:persName"/>
         </xsl:when>
         <xsl:when test="contains($entity, 'place')">
            <xsl:copy-of select="$nodes//TEI:placeName"/>
         </xsl:when>
         <xsl:when test="contains($entity, 'term')">
            <xsl:copy-of select="$nodes//TEI:term"/>
         </xsl:when>
         <xsl:when test="contains($entity, 'bibl')">
            <xsl:copy-of select="$nodes//TEI:bibl"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">Unsupported entity: <xsl:value-of select="$entity"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="a18:get-page-nr" as="xs:string">
      <xsl:param name="node" as="element()"/>
      <xsl:choose>
         <xsl:when test="$node/preceding::TEI:pb[1]/@n">
            <xsl:value-of select="$node/preceding::TEI:pb[1]/@n"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="count($node/preceding::TEI:pb)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>
