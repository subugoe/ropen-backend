<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tgn="http://textgrid.info/namespaces/vocabularies/tgn"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:kml="http://www.opengis.net/kml/2.2"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="TEI tgn xd xs archaeo18lib"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Sep 28, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="identifier" select="''"/>
   <xsl:param name="link-prefix" select="'http://134.76.21.92:8080/images/'"/>
   <xsl:include href="gettyLib.xsl"/>
   <xsl:param name="pageAsYear" select="false()" as="xs:boolean"/>
   <xsl:param name="linkImage" select="false()" as="xs:boolean"/>
   <xsl:param name="showSource" select="true()" as="xs:boolean"/>
   <xsl:param name="description" select="true()" as="xs:boolean"/>
   <xsl:param name="normalize" select="false()" as="xs:boolean"/>
   <xsl:param name="normalizeBase" select="300"/>
   <xsl:param name="filter" select="true()" as="xs:boolean"/>
   <xsl:variable name="imageURLSuffix">.jpeg</xsl:variable>
   <xsl:variable name="normalizeFactor" select="$normalizeBase div count(//TEI:pb)"/>
   <!-- <xsl:output encoding="UTF-8" method="xml" indent="yes"/> -->
   <xsl:template match="/">
      <xsl:message>
         <xsl:text>Configuration: </xsl:text>
         <xsl:text>Variables: </xsl:text>
         <xsl:text>identifier=</xsl:text>
         <xsl:value-of select="$identifier"/>
         <xsl:text>| linkImage=</xsl:text>
         <xsl:value-of select="$linkImage"/>
         <xsl:text>| description=</xsl:text>
         <xsl:value-of select="$description"/>
         <xsl:text>| pageAsYear=</xsl:text>
         <xsl:value-of select="$pageAsYear"/>
            <!--
            <xsl:text>| imageURLPrefix=</xsl:text>
            <xsl:value-of select="$imageURLPrefix"/>
            --><xsl:text>| imageURLSuffix=</xsl:text>
         <xsl:value-of select="$imageURLSuffix"/>
         <xsl:text>| normalize=</xsl:text>
         <xsl:value-of select="$normalize"/>
         <xsl:text>| normalizeBase=</xsl:text>
         <xsl:value-of select="$normalizeBase"/>
      </xsl:message>
      <kml xmlns="http://www.opengis.net/kml/2.2">
         <Document>
            <xsl:apply-templates/>
         </Document>
      </kml>
   </xsl:template>
   <xsl:template match="TEI:placeName" mode='kml'>
      <xsl:variable name="gettyID" select="translate(@ref, $getty-id-prefix, '')"/>
      <xsl:if test="$gettyID != '' and $gettyID != '#'">
         <xsl:variable name="gettyEntry">
            <xsl:call-template name="queryGettyRef">
               <xsl:with-param name="ref" select="@ref"/>
            </xsl:call-template>
         </xsl:variable>
         <Placemark xmlns="http://www.opengis.net/kml/2.2">
            <xsl:variable name="name" select="normalize-space(string-join(./text(), ''))"/>
            <xsl:variable name="displayName">
               <xsl:choose>
                  <xsl:when test="./TEI:addName[@type = 'display']">
                     <xsl:value-of select="./TEI:addName[@type = 'display']/text()"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$name"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <address>
               <xsl:call-template name="CDATA">
                  <xsl:with-param name="node" select="$displayName"/>
               </xsl:call-template>
                    <!--
                    <xsl:value-of select="$name"/>
                    --></address>
            <name>
               <xsl:call-template name="CDATA">
                  <xsl:with-param name="node" select="$displayName"/>
               </xsl:call-template>
                    <!--
                    <xsl:value-of select="$displayName"/>
                    --></name>
            <xsl:variable name="pageNr">
               <xsl:choose>
                  <xsl:when test="$normalize != true()">
                     <xsl:value-of select="count(preceding::TEI:pb) + 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="floor((count(preceding::TEI:pb) + 1) * $normalizeFactor)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="desc">
               <xsl:if test="$linkImage = true() and (@archaeo18lib:source-document or $identifier)">
                  <xsl:variable name="imageURLPrefix">
                     <xsl:choose>
                        <xsl:when test="@archaeo18lib:source-document">
                           <xsl:value-of select="concat($link-prefix, @archaeo18lib:source-document, '/120/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="concat($link-prefix, $identifier, '/120/')"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="imageNr">
                     <xsl:number format="00000001" value="$pageNr"/>
                  </xsl:variable>
                  <xsl:element name="h1">
                     <xsl:text>Image</xsl:text>
                  </xsl:element>
                  <xsl:element name="img">
                     <xsl:attribute name="alt">
                        <xsl:text>Page </xsl:text>
                        <xsl:value-of select="$pageNr"/>
                     </xsl:attribute>
                     <xsl:attribute name="src">
                        <xsl:value-of select="concat($imageURLPrefix, $imageNr, $imageURLSuffix)"/>
                     </xsl:attribute>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$description = true()">
                  <xsl:variable name="gettyURL">
                     <xsl:call-template name="getGettyURL">
                        <xsl:with-param name="id" select="$gettyID"/>
                     </xsl:call-template>
                  </xsl:variable>
                  <xsl:element name="h1">
                     <xsl:text>Description of "</xsl:text>
                     <xsl:choose>
                        <xsl:when test="$gettyURL != ''">
                           <xsl:element name="a">
                              <xsl:attribute name="href" select="$gettyURL"/>
                              <xsl:value-of select="$displayName"/>
                           </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="$displayName"/>
                        </xsl:otherwise>
                     </xsl:choose>
                     <xsl:text>"</xsl:text>
                  </xsl:element>
                        <!-- Use this if CDATA stuff is working disable-output-escaping="yes" --><xsl:call-template name="getDesc">
                     <xsl:with-param name="node" select="$gettyEntry"/>
                  </xsl:call-template>
                  <xsl:if test="$showSource = true()">
                     <xsl:element name="p">
                        <xsl:text>Description from </xsl:text>
                        <xsl:element name="a">
                           <xsl:attribute name="href" select="'http://www.getty.edu/'"/>
                           <xsl:text>Getty Thesaurus</xsl:text>
                        </xsl:element>
                     </xsl:element>
                  </xsl:if>
               </xsl:if>
            </xsl:variable>
            <description>
               <xsl:call-template name="CDATA">
                  <xsl:with-param name="node" select="$desc"/>
               </xsl:call-template>
                    <!--
                <xsl:copy-of select="$desc"/>
               --></description>
            <xsl:variable name="coords">
               <xsl:call-template name="hasCoord">
                  <xsl:with-param name="node" select="$gettyEntry"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$coords != 'false'">
               <Point>
                  <coordinates>
                     <xsl:call-template name="getLon">
                        <xsl:with-param name="node" select="$gettyEntry"/>
                     </xsl:call-template>
                     <xsl:text>,</xsl:text>
                     <xsl:call-template name="getLat">
                        <xsl:with-param name="node" select="$gettyEntry"/>
                     </xsl:call-template>
                  </coordinates>
               </Point>
            </xsl:if>
            <xsl:if test="$pageAsYear != false()">
               <TimeStamp>
                  <when>
                     <xsl:value-of select="$pageNr"/>
                  </when>
               </TimeStamp>
            </xsl:if>
         </Placemark>
      </xsl:if>
   </xsl:template>
   <xsl:template match="TEI:addName" mode='kml'>
      <xsl:if test="not($filter)">
         <xsl:apply-templates/>
      </xsl:if>
   </xsl:template>
    <!--
    <xsl:template match="text()" mode="name">
        <xsl:value-of select="normalize-space(.)"></xsl:value-of>
    </xsl:template>
    --><xsl:template match="text()" mode='kml'/>
   <xsl:template name="CDATA">
      <xsl:param name="node"/>
      <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
      <xsl:copy-of select="$node"/>
      <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
   </xsl:template>
</xsl:stylesheet>
