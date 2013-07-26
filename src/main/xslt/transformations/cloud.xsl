<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs xd"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Jun 18, 2012</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:output encoding="UTF-8"
               doctype-public="-//W3C//DTD XHTML 1.1//EN"
               doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
               indent="no"
               method="xhtml"/>
   <xsl:param name="groupRowsParam" select="false()"/>
   <xsl:param name="dupliatePagesParam" select="false()"/>
   <xsl:variable name="groupRows"
                 select="if ($groupRowsParam castable as xs:boolean) then xs:boolean($groupRowsParam) else false()"
                 as="xs:boolean"/>
   <xsl:variable name="dupliatePages"
                 select="if ($dupliatePagesParam castable as xs:boolean) then xs:boolean($dupliatePagesParam) else false()"
                 as="xs:boolean"/>
   <xsl:template match="/">
      <html xhtml="http://www.w3.org/1999/xhtml">
         <head/>
         <body>
            <table>
               <thead>
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
               </thead>
               <tbody>
                  <xsl:apply-templates/>
               </tbody>
               <tfoot>
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
               </tfoot>
            </table>
         </body>
      </html>
   </xsl:template>
   <xsl:template match="tag[not(parent::tag)]">
      <xsl:variable name="link">
         <xsl:value-of select="./link"/>
      </xsl:variable>
      <xsl:variable name="num-docs">
         <xsl:value-of select="count(distinct-values(./pages/page/@doc))"/>
      </xsl:variable>
      <xsl:variable name="context" select="."/>
      <xsl:variable name="entity-cell">
         <td>
            <xsl:if test="$groupRows = true()">
               <xsl:attribute name="rowspan">
                  <xsl:value-of select="$num-docs"/>
               </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="entity-name">
               <xsl:with-param name="link" select="$link"/>
            </xsl:call-template>
         </td>
      </xsl:variable>
      <xsl:for-each select="distinct-values(./pages/page/@doc)">
         <xsl:variable name="doc-id">
            <xsl:value-of select="."/>
         </xsl:variable>
         <tr>
            <xsl:if test="$groupRows != true() or ($groupRows = true() and position() = 1)">
               <xsl:copy-of select="$entity-cell"/>
            </xsl:if>
            <td>
               <xsl:value-of select="."/>
            </td>
            <td>
               <xsl:call-template name="page-links">
                  <xsl:with-param name="context" select="$context"/>
                  <xsl:with-param name="doc-id" select="$doc-id"/>
               </xsl:call-template>
            </td>
         </tr>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="tag[not(parent::tag)]" mode="classic">
      <xsl:variable name="link">
         <xsl:value-of select="./link"/>
      </xsl:variable>
      <xsl:variable name="name">
         <xsl:value-of select="./tag"/>
      </xsl:variable>
      <tr>
         <xsl:for-each select=".//page">
            <td>
               <xsl:choose>
                  <xsl:when test="@variant">
                     <xsl:value-of select="@variant"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$name"/>
                  </xsl:otherwise>
               </xsl:choose>
            </td>
            <td>
               <xsl:value-of select="@doc"/>
            </td>
            <td>
               <a>
                  <xsl:attribute name="href">
                     <xsl:text>#p</xsl:text>
                     <xsl:value-of select="@n"/>
                  </xsl:attribute>
                  <xsl:if test="@variant">
                     <xsl:attribute name="title">
                        <xsl:value-of select="@variant"/>
                     </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="@n"/>
               </a>
            </td>
         </xsl:for-each>
      </tr>
   </xsl:template>
   <xsl:template name="entity-name">
      <xsl:param name="link" select="''"/>
      <xsl:choose>
         <xsl:when test="$link != ''">
            <a target="_blank">
               <xsl:attribute name="href">
                  <xsl:value-of select="$link"/>
               </xsl:attribute>
               <xsl:value-of select="./tag"/>
            </a>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="./tag"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="page-links">
      <xsl:param name="context"/>
      <xsl:param name="doc-id"/>
      <xsl:for-each select="$context/pages/page[@doc = $doc-id]">
            <!-- Check for duplicates here not(data(preceding-sibling::page/@n) = data(@n) and data(preceding-sibling::page/@doc) = data(@doc)) --><xsl:if test="@n and (not(data(preceding-sibling::page/@n) = data(@n) and data(preceding-sibling::page/@doc) = data(@doc)) or $dupliatePages)">
            <a class="editionRef">
                    <!--
                <xsl:attribute name="href">
                    <xsl:text>#p</xsl:text>
                    <xsl:value-of select="@n"/>
                </xsl:attribute>
                --><xsl:attribute name="rel">
                  <xsl:value-of select="$doc-id"/>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="@n"/>
               </xsl:attribute>
               <xsl:if test="@variant">
                  <xsl:attribute name="title">
                     <xsl:call-template name="clearTitle">
                        <xsl:with-param name="variant" select="@variant"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </xsl:if>
               <xsl:value-of select="@n"/>
            </a>
                <!-- This only works for one document --><xsl:if test="position() != last() or not(following-sibling::page/@doc = $doc-id)">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="clearTitle">
        <!-- TODO: This should be dono inside the databas--><xsl:param name="variant"/>
        <!-- Remove hyphen --><xsl:variable name="withoutHyphen" select="replace($variant, '-&#xA;\s*','')"/>
        <!-- remove line break --><xsl:value-of select="replace($variant, '&#xA;\s*',' ')"/>
   </xsl:template>
    <!-- See http://stackoverflow.com/questions/6493769/is-there-an-exclusive-or-xor-in-xpath
    <xsl:function name="fn:xor">
        <xsl:param name="pX" as="xs:boolean"/>
        <xsl:param name="pY" as="xs:boolean"/>
        
        <xsl:sequence select=
            "$pX and not($pY)   or   $pY and not($pX)"/>
    </xsl:function>
    --></xsl:stylesheet>
