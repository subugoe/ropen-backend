<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:METS="http://www.loc.gov/METS/"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd xs METS TEI xsl" version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Aug 4, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="output-param" select="'tei'"/>
   <xsl:param name="filter" select="true()" as="xs:boolean"/>
   <xsl:variable name="output" select="if ($output-param castable as xs:string) then xs:string($output-param) else 'tei'" as="xs:string"/>
   <xsl:strip-space elements="TEI:*"/>

   <!-- input seed here -->
   <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" standalone="yes" indent="yes"/>
   <xsl:variable name="locPrefix">loc</xsl:variable>
   <xsl:template match="/">
      <xsl:choose>
         <xsl:when test="$output = 'tei'">
            <xsl:apply-templates mode="tei"/>
         </xsl:when>
         <xsl:when test="$output = 'mets'">
            <xsl:apply-templates mode="mets"/>
         </xsl:when>
         <xsl:when test="$output = 'xhtml'">
            <xsl:apply-templates mode="xhtml-structure"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">Unknown output mode: <xsl:value-of select="$output"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template match="TEI:TEI" mode="tei">
      <TEI:TEI>
         <TEI:teiHeader> </TEI:teiHeader>
         <TEI:text>
            <TEI:body>
               <xsl:apply-templates select="/TEI:TEI/TEI:text/TEI:body" mode="tei"/>
            </TEI:body>
         </TEI:text>
      </TEI:TEI>
   </xsl:template>
   
   <xsl:template match="TEI:TEI" mode="mets">
      <METS:mets>
         <METS:structMap TYPE="LOGICAL">
            <METS:div TYPE="Monograph" DMDID="dmdSec_00000001" ADMID="amdSec_00000001">
               <xsl:attribute name="ID">
                  <xsl:value-of select="$locPrefix"/>
                  <xsl:text>_</xsl:text>
                  <xsl:number format="00000001" value="1"/>
               </xsl:attribute>
               <xsl:apply-templates select="/TEI:TEI/TEI:text/TEI:body" mode="mets"/>
            </METS:div>
         </METS:structMap>
      </METS:mets>
   </xsl:template>
   
   <xsl:template match="TEI:TEI" mode="xhtml-structure">
      <html xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns="http://www.w3.org/1999/xhtml" xmlns:foaf="http://xmlns.com/foaf/0.1/"
         xmlns:bibo="http://purl.org/ontology/bibo/1.3/" version="XHTML+RDFa 1.0">
         <head>
            <title>
               <xsl:attribute name="type">dc:title</xsl:attribute>
               <xsl:value-of select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]/text()"/>
            </title>
         </head>
         <body>
            <xsl:apply-templates select="/TEI:TEI/TEI:text/TEI:body" mode="xhtml-structure"/>
         </body>
      </html>
   </xsl:template>
   
   <xsl:template match="TEI:div" mode="mets">
      <xsl:choose>
         <!-- Get rid of empty div tags -->
         <xsl:when test="TEI:head">
            <METS:div>
               <xsl:apply-templates select="TEI:div|TEI:head" mode="mets"/>
            </METS:div>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="TEI:div|TEI:head" mode="mets"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="TEI:head" mode="mets">
      <xsl:attribute name="ID">
         <xsl:value-of select="$locPrefix"/>
         <xsl:text>_</xsl:text>
         <xsl:number format="00000001" value="count(preceding::TEI:head) + 5"/>
      </xsl:attribute>
      <xsl:attribute name="TYPE">
         <xsl:text>chapter</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="LABEL">
         <!-- Use this to remove line seperators -->
         <!--
                <xsl:value-of select="replace(normalize-space(.), '- ', '')"/>
            -->
         <xsl:value-of select="normalize-space(.)"/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="TEI:head" mode="tei">
      <TEI:head>
         <!-- Use this to remove line seperators -->
         <!--
                <xsl:value-of select="replace(normalize-space(.), '- ', '')"/>
            -->
         <xsl:value-of select="normalize-space(.)"/>
      </TEI:head>
   </xsl:template>
   <xsl:template match="TEI:div" mode="tei">
      <xsl:choose>
         <!-- Get rid of empty div tags -->
         <xsl:when test="TEI:head">
            <TEI:div>
               <xsl:if test="@id">
                  <xsl:attribute name="id">
                     <xsl:value-of select="@id"/>
                  </xsl:attribute>
               </xsl:if>
               <xsl:apply-templates select="TEI:div|TEI:head|TEI:pb" mode="tei"/>
            </TEI:div>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="TEI:div|TEI:head|TEI:pb" mode="tei"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="TEI:pb" mode="tei">
      <TEI:pb>
         <xsl:if test="@id">
            <xsl:attribute name="id">
               <xsl:value-of select="@id"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:attribute name="n">
            <xsl:value-of select="count(preceding::TEI:pb)"/>
         </xsl:attribute>
      </TEI:pb>
   </xsl:template>
   <xsl:template match="TEI:note" mode="#all"/>
   <xsl:template match="TEI:head" mode="xhtml-structure">
      <xsl:element name="{concat('h', count(ancestor::TEI:div))}" namespace="http://www.w3.org/1999/xhtml">
         <xsl:variable name="id">
            <xsl:value-of select="parent::TEI:div/@id"/>
         </xsl:variable>
         <xsl:variable name="name">
            <xsl:apply-templates mode="xhtml-structure"/>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="$id != ''">
               <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                  <xsl:attribute name="name">
                     <xsl:value-of select="$id"/>
                  </xsl:attribute>
                  <xsl:attribute name="class">
                     <xsl:value-of select="concat(local-name(.), '-anchor')"/>
                  </xsl:attribute>
                  <xsl:value-of select="$name"/>


                  <!--
                            <xsl:value-of select="normalize-space(string-join($name/text(), ''))"/>
                    <xsl:apply-templates/>
                    -->
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$name"/>
               <!--
                        <xsl:value-of select="normalize-space(string-join($name/text(), ''))"/>
                    <xsl:apply-templates/>
                    -->
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
      <xsl:if test="count(ancestor::TEI:div) &gt; 9">
         <xsl:message terminate="yes">Nesting to high, max is 9, <xsl:value-of select="count(ancestor::TEI:div)"/> given!</xsl:message>
      </xsl:if>
   </xsl:template>
   <xsl:template match="TEI:lb" mode="xhtml-structure">
      <xsl:text> </xsl:text>
   </xsl:template>
   <xsl:template match="TEI:div" mode="xhtml-structure">
      <xsl:choose>
         <!-- Get rid of empty div tags -->
         <xsl:when test="TEI:head">
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
               <xsl:if test="@id">
                  <xsl:attribute name="id">
                     <xsl:value-of select="@id"/>
                  </xsl:attribute>
               </xsl:if>
               <xsl:apply-templates select="TEI:div|TEI:head|TEI:pb|TEI:lb" mode="xhtml-structure"/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="TEI:div|TEI:head|TEI:pb" mode="xhtml-structure"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="TEI:pb" mode="xhtml-structure">
      <xsl:element name="hr" namespace="http://www.w3.org/1999/xhtml"/>
   </xsl:template>
   <xsl:template match="TEI:addName" mode="#all">
      <xsl:if test="not($filter)">
         <xsl:apply-templates/>
      </xsl:if>
   </xsl:template>
   <!--
    <xsl:template match="text()" mode="#all"/>
    -->
</xsl:stylesheet>
