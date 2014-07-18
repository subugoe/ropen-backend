<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
   xmlns="http://www.w3.org/1999/xhtml" version="2.0">
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
   <xsl:param name="dupliate-pages-param" select="true()"/>
   <xsl:param name="entity-param" select="'TEI:persName'"/>
   <xsl:param name="mode-param" select="''"/> 
   <xsl:param name="cloudout-param" select="''" />
   <xsl:param name="doc-name-param" select="''"/>
   <xsl:param name="collection-param" select="''"/>
   <xsl:param name="verbose" select="false()" as="xs:boolean"/>
   <xsl:variable name="group-rows" select="if ($group-rows-param castable as xs:boolean) then xs:boolean($group-rows-param) else true()" as="xs:boolean"/>
   <xsl:variable name="dupliate-pages" select="if ($dupliate-pages-param castable as xs:boolean) then xs:boolean($dupliate-pages-param) else false()" as="xs:boolean"/>
   <xsl:variable name="entity" select="if ($entity-param castable as xs:string and $entity-param != '') then xs:string($entity-param) else 'TEI:persName|TEI:placeName|TEI:term|TEI:bibl'" as="xs:string"/>
   <xsl:variable name="mode" select="if ($mode-param castable as xs:string) then xs:string($mode-param) else 'cloud'" as="xs:string"/>
   <xsl:variable name="cloudout" select="if ($cloudout-param castable as xs:string) then xs:string($cloudout-param) else ''" as="xs:string"/>
   <xsl:variable name="doc-name" select="if ($doc-name-param castable as xs:string) then xs:string($doc-name-param) else ''" as="xs:string"/>
   <xsl:variable name="collection" select="if ($collection-param != '' and collection($collection-param)) then collection($collection-param) else ()" as="node()*"/>
   <xsl:output method="xml" indent="yes"/>
   <xsl:param name="pages" select="''" />
   <xsl:variable name="prefix" select="'TEI:'"/>
   <xsl:variable name="placeholder-prefix" select="'#placeholder-'"/>
   <xsl:include href="./lib/a18.xsl"/>
   <xsl:include href="./lib/ropen.xsl"/>
   <xsl:template match="/">
      <xsl:variable name="content">
         <xsl:choose>
            <xsl:when test="not(empty($collection))">
               <!--
               <xsl:apply-templates select="$collection" mode="add-doc"/>
               -->
               <xsl:copy-of select="a18:merge-bodies($collection)"/>
               <!--<xsl:copy-of select="$collection"/>-->
            </xsl:when>
            <xsl:when test="not(empty($doc-name)) and $doc-name != ''">
               <xsl:apply-templates select="doc($doc-name)" mode="add-doc"/>
               <!--<xsl:copy-of select="doc($doc-name)"/>-->
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="." mode="add-doc"/>
               <!--<xsl:copy-of select="."/>-->
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>      
         <xsl:when test="$mode = 'cloud' or $mode= 'cloud-pages'">
            <xsl:choose>
            <xsl:when test="$cloudout != ''">             
               <xsl:for-each select="collection(concat($collection-param, '/?select=*.xml'))">
                  <xsl:variable name="in-file" select="ropen:uri-to-name(replace(tokenize(document-uri(.), '/')[last()], '.tei', ''))" as="xs:string"/>
                  <xsl:variable name="page-id" select="if( $pages != '0') then '' else concat('-', $pages)"/>
                  <xsl:variable name="entity-id" select="if (contains($entity, '|')) then '' else concat('-', tokenize($entity, ':')[last()])" as="xs:string"/>
                  <xsl:variable name="outfile" select="ropen:concat-path($cloudout, concat($in-file, $page-id, $entity-id, '.xml'))" as="xs:anyURI"/>    
                  <xsl:message terminate="no">Generating tag file <xsl:value-of select="$outfile"/></xsl:message>
                  <xsl:variable name="thiscont">
                     <xsl:element name="TEI:body">
                     <xsl:apply-templates select="//TEI:body/*" mode="add-doc"/>
                     </xsl:element>
                     <!--<xsl:copy-of select="." />-->
                  </xsl:variable>
                  <xsl:result-document href="{$outfile}" encoding="UTF-8">
                     <xsl:choose>
                        <xsl:when test="$mode = 'cloud'">
                           <xsl:apply-templates select="$thiscont" mode="cloud"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:apply-templates select="$thiscont" mode="cloud-pages"/>
                        </xsl:otherwise>
                     </xsl:choose> 
                  </xsl:result-document>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
            <xsl:apply-templates select="$content" mode="cloud"/>
            </xsl:otherwise>
            </xsl:choose>
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
      <xsl:variable name="variant" as="text()">
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
            <xsl:value-of select="ropen:normalize-space($variant)"/>
         </xsl:attribute>
         <xsl:apply-templates select="@doc"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="@*">
      <xsl:copy/>
   </xsl:template>
   <!-- Tags to ignore -->
   <xsl:template match="TEI:addName"/>
   <xsl:template match="TEI:persName|TEI:placeName|TEI:term|TEI:bibl">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="text()">
      <xsl:value-of select="normalize-space(.)"/>
   </xsl:template>

 <xsl:template match="//TEI:body" mode="cloud-pages">
      <tags>
         <xsl:for-each-group select="a18:resolve-entity($entity, .)" group-by="@ref|./TEI:ref/@target">      
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
                  <xsl:value-of select="concat(lower-case($prefix), local-name(current-group()[1]))"/>
               </facet>
               <xsl:for-each select="distinct-values(current-group()[1]/@ref)">
                  <link>
                     <xsl:value-of select="a18:resolve-id(.)"/>
                  </link>
               </xsl:for-each>
               <count>
                  <xsl:value-of select="count(current-group())"/>
               </count>
               <nodes> 
                  <xsl:element name="{name()}">
                     <xsl:attribute name="ref"><xsl:value-of select="./@ref" /></xsl:attribute>
                     <xsl:attribute name="key"><xsl:value-of select="./@key" /></xsl:attribute>
                     <xsl:copy-of select="current-group()[1]/*" />
                  </xsl:element>
               </nodes>
            </tag>
         </xsl:for-each-group>
      </tags>
   </xsl:template>

   <xsl:template match="//TEI:body" mode="cloud">
      <tags>
         <xsl:for-each-group select="a18:resolve-entity($entity, .)" group-by="@ref|./TEI:ref/@target">      
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
                        <xsl:variable name="variant" as="text()*">
                           <xsl:apply-templates/>
                        </xsl:variable>
                        <xsl:attribute name="doc">
                           <xsl:value-of select="ropen:uri-to-name(a18:get-document(., false()))"/>
                        </xsl:attribute>
                        <xsl:attribute name="n">
                           <xsl:choose>
                              <xsl:when test="@a18:_n">
                                 <xsl:value-of select="@a18:_n"/>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:value-of select="a18:get-page-nr(.)"/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="variant">
                           <xsl:value-of select="ropen:normalize-space($variant)"/>
                        </xsl:attribute>
                     </page>
                  </xsl:for-each>
               </pages>
            </tag>
         </xsl:for-each-group>
      </tags>
   </xsl:template>
   <xsl:template match="//TEI:body" mode="xhtml">
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
                  <xsl:for-each-group select="a18:resolve-entity($entity, .)" group-by="@ref|./TEI:ref/@target">
                     <!-- <xsl:sort select=".//TEI:addName[@type = 'display']" order="ascending"/> -->
                     <xsl:sort select="." order="ascending"/>
                     <xsl:variable name="link">
                        <xsl:choose>
                           <xsl:when test="starts-with(@ref, $placeholder-prefix) or starts-with(./TEI:ref/@target, $placeholder-prefix)">
                              <xsl:value-of select="''"/>
                           </xsl:when>
                           <xsl:when test="@ref">
                              <xsl:value-of select="a18:resolve-id(@ref)"/>
                           </xsl:when>
                           <xsl:when test="./TEI:ref/@target">
                              <xsl:value-of select="a18:resolve-id(./TEI:ref/@target)"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="''"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:variable>
                     <xsl:variable name="tag">
                        <xsl:choose>
                           <xsl:when test="current-group()//TEI:addName[@type = 'display']">
                              <xsl:value-of select="(current-group()//TEI:addName[@type = 'display'])[1]/text()"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:variable name="variant" as="text()*">
                                 <xsl:apply-templates select="current-group()[1]/node()"/>
                              </xsl:variable>
                              <xsl:value-of select="ropen:normalize-space($variant)"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:variable>
                     <!--
                     <xsl:variable name="num-docs">
                        <xsl:value-of select="count(distinct-values(current-group()/@a18:_doc))"/>
                     </xsl:variable>
                     -->
                     <xsl:variable name="entity-cell">
                        <td>
                           <xsl:if test="$group-rows = true()">
                              <xsl:attribute name="rowspan">
                                 <xsl:value-of select="count(distinct-values(current-group()/@a18:_doc))"/>
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
                     <!-- TODO: Check if entry contains word chars, this currently let's entries like "1ste" or roman numerals pass -->
                     <xsl:if test="not(matches($tag, '^[\d\.\s:-]*$'))">
                        <xsl:for-each-group select="current-group()" group-by="@a18:_doc">
                           <xsl:sort select="a18:get-document(., true())" order="ascending"/>
                           <xsl:variable name="doc-id">
                              <xsl:value-of select="ropen:uri-to-name(a18:get-document(., false()))"/>
                           </xsl:variable>
                           <xsl:variable name="doc-title">
                              <xsl:value-of select="a18:get-document(., true())"/>
                           </xsl:variable>
                           <tr>
                              <xsl:if test="not($group-rows) or ($group-rows and position() = 1)">
                                 <xsl:copy-of select="$entity-cell"/>
                              </xsl:if>
                              <td>
                                 <xsl:value-of select="$doc-title"/>
                              </td>
                              <td>
                                 <xsl:copy-of select="a18:page-links(current-group(), $doc-id)"/>
                              </td>
                           </tr>
                        </xsl:for-each-group>
                     </xsl:if>
                  </xsl:for-each-group>
               </tbody>
               <tfoot>
                  <xsl:copy-of select="$description"/>
               </tfoot>
            </table>
         </body>
      </html>
   </xsl:template>
   <xsl:function name="a18:page-links" as="node()*">
      <xsl:param name="nodes" as="node()*"/>
      <xsl:param name="doc-id" as="xs:string"/>
      <xsl:variable name="filtered-nodes" as="node()*">
         <xsl:choose>
            <xsl:when test="$dupliate-pages">
               <xsl:copy-of select="$nodes"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:for-each select="distinct-values($nodes//*/@a18:_n)">
                  <xsl:variable name="page" select="."/>
                  <xsl:copy-of select="$nodes[@a18:_n = $page][1]"/>
               </xsl:for-each>
               <!--
               <xsl:copy-of select="a18:distict-pages($nodes)"/>
               -->
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="$filtered-nodes">
         <xsl:variable name="page-nr" as="xs:string">
            <xsl:value-of select="./@a18:_n"/>
         </xsl:variable>
         <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
            <xsl:variable name="variant" as="text()*">
               <xsl:apply-templates/>
            </xsl:variable>
            <xsl:attribute name="class" select="'editionRef'"/>
            <xsl:attribute name="rel">
               <xsl:value-of select="$doc-id"/>
               <xsl:text>;</xsl:text>
               <xsl:value-of select="$page-nr"/>
            </xsl:attribute>
            <xsl:attribute name="title">
               <xsl:value-of select="ropen:normalize-space($variant)"/>
            </xsl:attribute>
            <xsl:value-of select="$page-nr"/>
         </xsl:element>
         <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
         </xsl:if>
      </xsl:for-each>
   </xsl:function>

   <!-- Get distinct pages, see http://stackoverflow.com/questions/18451205/xpath-to-select-unique-list-of-elements-that-have-a-certain-attribute-with-xpath -->
   <xsl:function name="a18:distict-pages" as="node()*">
      <xsl:param name="nodes" as="node()*"/>
      <xsl:for-each select="distinct-values($nodes//*/@a18:_n)">
         <xsl:variable name="page" select="."/>
         <xsl:copy-of select="$nodes[@a18:_n = $page][1]"/>
      </xsl:for-each>
   </xsl:function>

   <!-- Ignore the header -->
   <xsl:template match="TEI:teiHeader" mode="cloud xhtml cloud-pages"/>
   <!-- Templates to add the document name of a element to each element -->
   <!-- Entities -->
   <!--
   <xsl:template match="TEI:bibl|TEI:ref|TEI:placeName|TEI:persName|TEI:term|TEI:addName[@type]" mode="add-doc">
      <xsl:copy>
         <xsl:attribute name="_doc" select="document-uri(root(.))" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <xsl:attribute name="_n" select="count(preceding::TEI:pb) + 1" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <xsl:apply-templates select="@*|node()" mode="add-doc"/>
      </xsl:copy>
   </xsl:template>
   -->
<!--   <xsl:template match="TEI:addName[@type]" mode="add-doc"> -->
      <xsl:template match="TEI:addName" mode="add-doc">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="add-doc"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:bibl|TEI:placeName|TEI:persName|TEI:term" mode="add-doc">
      <xsl:copy>
         <xsl:attribute name="_doc" select="document-uri(root(.))" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <xsl:attribute name="_n" select="count(preceding::TEI:pb) + 1" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <!-- no reference or bogus attribute -->
         <xsl:if test="not(. instance of element(TEI:bibl)) and not(@ref) or @ref = '#'">
            <xsl:variable name="placeholder" select="concat($placeholder-prefix, document-uri(root(.)), '-', generate-id(.))"/>
            <xsl:attribute name="ref" select="$placeholder"/>
            <xsl:if test="$verbose">
               <xsl:message>Generated placeholder reference: <xsl:value-of select="$placeholder"/> for element <xsl:value-of select="name(.)"/> at <xsl:value-of
                     select="ropen:generate-xpath(., true())"/></xsl:message>
            </xsl:if>
         </xsl:if>
         <xsl:if test=". instance of element(TEI:bibl) and not(./TEI:ref)">
            <xsl:element name="TEI:ref">
               <xsl:attribute name="target" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:variable name="placeholder" select="concat($placeholder-prefix, document-uri(root(.)), '-', generate-id(.))"/>
                  <xsl:attribute name="target" select="$placeholder"/>
                  <xsl:if test="$verbose">
                     <xsl:message>Generated placeholder reference: <xsl:value-of select="$placeholder"/> for element <xsl:value-of select="name(.)"/> at <xsl:value-of
                           select="ropen:generate-xpath(., true())"/></xsl:message>
                  </xsl:if>
               </xsl:attribute>
            </xsl:element>
         </xsl:if>
         <xsl:apply-templates select="@*|node()" mode="add-doc"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:ref" mode="add-doc">
      <xsl:copy>
         <xsl:attribute name="_doc" select="document-uri(root(.))" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <xsl:attribute name="_n" select="count(preceding::TEI:pb) + 1" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <!-- no reference or bogus attribute -->
         <xsl:if test="not(@target) or @target = '#'">
            <xsl:variable name="placeholder" select="concat($placeholder-prefix, document-uri(root(.)), '-', generate-id(.))"/>
            <xsl:attribute name="target" select="$placeholder"/>
            <xsl:if test="$verbose">
               <xsl:message>Generated placeholder reference: <xsl:value-of select="$placeholder"/></xsl:message>
            </xsl:if>
         </xsl:if>
         <xsl:apply-templates select="@*|node()" mode="add-doc"/>
      </xsl:copy>
   </xsl:template>

   <!-- Pagebreaks -->
   <xsl:template match="TEI:pb" mode="add-doc">
      <xsl:copy>
         <xsl:attribute name="_doc" select="document-uri(root(.))" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <xsl:attribute name="_n" select="count(preceding::TEI:pb) + 1" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
      </xsl:copy>
   </xsl:template>
   <!-- Stuff to ignore -->
   <xsl:template match="TEI:lb|comment()|processing-instruction()|TEI:note" mode="add-doc"/>
   
<!--   <xsl:template match="TEI:addName[not(@type)]|TEI:lb|comment()|processing-instruction()|TEI:note" mode="add-doc"/> -->
   <xsl:template match="TEI:teiHeader" mode="add-doc"/>
   <!-- Text handling -->
   <xsl:template match="@*|text()" mode="add-doc">
      <xsl:choose>
         <xsl:when test=". instance of text() and matches(., '^[\s\n]+$')"/>
         <!-- 
            <xsl:when test=". instance of text() and ancestor-or-self::TEI:teiHeader"/>
          -->
         <xsl:otherwise>
            <xsl:copy/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Preserve structure -->
   <xsl:template match="TEI:text|TEI:body|TEI:div|TEI:p" mode="add-doc">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="add-doc"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="TEI:TEI" mode="add-doc">
      <xsl:copy>
         <xsl:attribute name="_doc" select="document-uri(root(.))" namespace="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"/>
         <xsl:apply-templates select="@*|node()" mode="add-doc"/>
      </xsl:copy>
   </xsl:template>
   <!-- Get rid of all unneeded TEI Tags -->
   <xsl:template match="TEI:*" mode="add-doc">
      <xsl:apply-templates select="node()" mode="add-doc"/>
   </xsl:template>
   <!-- Functions - merge these with the libraries -->
   <xsl:function name="a18:clear-title" as="xs:string">
      <xsl:param name="variant"/>
      <!-- Remove hyphen and the line break -->
      <xsl:value-of select="ropen:normalize-space($variant)"/>
   </xsl:function>
   <!-- Gets either document title or id -->
   <xsl:function name="a18:get-document" as="xs:string">
      <xsl:param name="node" as="element()"/>
      <xsl:param name="display-name" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="not($display-name) and $node/@a18:_doc">
            <xsl:value-of select="$node/@a18:_doc"/>
         </xsl:when>
         <xsl:when test="not($display-name) and $doc-name != ''">
            <xsl:value-of select="$doc-name"/>
         </xsl:when>
         <xsl:when test="$display-name">
            <xsl:variable name="uri" select="if ($node/@a18:_doc) then $node/@a18:_doc else document-uri(root($node))"/>
            <xsl:variable name="display-title" select="a18:tei-display-title(doc($uri))"/>
            <xsl:choose>
               <xsl:when test="$display-title = ''">
                  <xsl:value-of select="'Title not available'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$display-title"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="identifier" select="ropen:document-name($node)"/>
            <xsl:choose>
               <xsl:when test="$identifier = ''">
                  <xsl:value-of select="'Identifier not available'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$identifier"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!--
   <xsl:function name="a18:merge" as="element(TEI:body)">
      <xsl:param name="nodes" as="node()*"/>
      <xsl:element name="TEI:body">
         <xsl:for-each select="$nodes//TEI:body/*">
            <xsl:copy-of select="."/>
         </xsl:for-each>
      </xsl:element>
   </xsl:function>
   -->
   <xsl:function name="a18:resolve-entity" as="element()*">
      <xsl:param name="entity"/>
      <xsl:param name="nodes" as="node()*"/>
     
      <xsl:if test="contains($entity, ',')">
         <xsl:message terminate="yes">Only one entity is currently supported</xsl:message>
      </xsl:if>
      <xsl:if test="contains($entity, 'pers')">
         <xsl:copy-of select="$nodes//TEI:persName"/>
      </xsl:if>
      <xsl:if test="contains($entity, 'place')">
         <xsl:copy-of select="$nodes//TEI:placeName"/>
      </xsl:if>
      <xsl:if test="contains($entity, 'term')">
         <xsl:copy-of select="$nodes//TEI:term"/>
      </xsl:if>
      <xsl:if test="contains($entity, 'bibl')">
         <xsl:copy-of select="$nodes//TEI:bibl"/>
      </xsl:if>
      
     <!-- <xsl:choose>
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
      </xsl:choose> -->
   </xsl:function>
   <!--
   <xsl:function name="a18:add-doc" as="node()*">
      <xsl:param name="nodes" as="node()*"/>
      <xsl:apply-templates select="$nodes" mode="add-doc"/>
   </xsl:function>
   -->
   <xsl:function name="a18:merge-bodies" as="element(TEI:body)">
      <xsl:param name="nodes" as="node()*"/>
      <!--
      <xsl:variable name="annotated-tei" select="a18:add-doc($nodes)" as="node()*"/>
      -->
      <xsl:element name="TEI:body">
         <xsl:apply-templates select="$nodes/TEI:TEI/TEI:text/TEI:body/*" mode="add-doc"/>
      </xsl:element>
   </xsl:function>

</xsl:stylesheet>
