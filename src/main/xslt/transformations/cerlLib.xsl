<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:marcxml="http://www.loc.gov/MARC21/slim"
                xmlns:ctas="http://sru.cerl.org/ctas/dtd/1.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xcql="http://www.loc.gov/zing/cql/xcql/"
                xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xd"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Sep 29, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>

    <!-- 
        Example URL:
        CTAS
        http://sru.cerl.org/thesaurus?operation=searchRetrieve&version=1.1&query=id%20any%20cnp00986106
        MarcXML
        http://sru.cerl.org/thesaurus?operation=searchRetrieve&version=1.1&recordSchema=marcxml&query=id%20any%20cnp00986106
    --><xsl:param name="urlPrefix"
              select="'http://sru.cerl.org/thesaurus?operation=searchRetrieve&amp;version=1.1&amp;'"/>

    <!-- Needed for EXSL vs. XSLT 2.0 related Saxon problems. -->
    <!--
    <xsl:include href="./lib/xsl-compat.xsl"/>
    -->
    <!-- Remove this (set formatString as empty string) to get the shorter CTAS format, see
        http://www.cerl.org/web/_media/en/resources/cerl_thesaurus/ctas_v11.pdf?id=en%3Aresources%3Acerl_thesaurus%3Asru&cache=cache --><xsl:param name="formatString" select="'recordSchema=marcxml&amp;'"/>
   <xsl:param name="queryPrefix" select="'query='"/>
   <xsl:param name="idPrefix" select="'id any '"/>
   <xsl:param name="debug" select="false()"/>
   <xsl:variable name="cerl-id-prefix" select="'#CerlID:'"/>
   <xsl:template name="extractCerlId">
      <xsl:param name="ref"/>
      <xsl:variable name="cerlID">
         <xsl:value-of select="translate($ref, $cerl-id-prefix, '')"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="string-length($cerlID) &gt; 3">
            <xsl:value-of select="$cerlID"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="''"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="queryCerlRef">
      <xsl:param name="ref"/>
      <xsl:variable name="cerlID" select="translate($ref, $cerl-id-prefix, '')"/>
      <xsl:call-template name="queryCerl">
         <xsl:with-param name="id" select="$cerlID"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="queryCerl">
      <xsl:param name="id"/>
      <xsl:if test="string-length($id) &lt; 1">
         <xsl:message>No Valid id given!</xsl:message>
      </xsl:if>
      <xsl:variable name="queryString"
                    select="concat($queryPrefix, encode-for-uri(concat($idPrefix,$id)))"/>
      <xsl:variable name="queryURL"
                    select="concat($urlPrefix, $formatString, $queryString)"/>
      <xsl:message>
            Query URL: <xsl:value-of select="$queryURL"/>
      </xsl:message>
      <xsl:variable name="cerlEntry" select="document($queryURL)//srw:record"/>
      <xsl:copy-of select="$cerlEntry"/>
   </xsl:template>
   <xsl:template name="queryCerlMarcXML">
      <xsl:param name="id"/>
      <xsl:if test="string-length($id) &lt; 1">
         <xsl:message>No Valid id given!</xsl:message>
      </xsl:if>
      <xsl:variable name="queryString"
                    select="concat($queryPrefix, encode-for-uri(concat($idPrefix,$id)))"/>
      <xsl:variable name="queryURL"
                    select="concat($urlPrefix, $formatString, $queryString)"/>
      <xsl:message>
            Query URL: <xsl:value-of select="$queryURL"/>
      </xsl:message>
      <xsl:variable name="cerlEntry" select="document($queryURL)//srw:record"/>
      <xsl:copy-of select="$cerlEntry"/>
   </xsl:template>
   <xsl:template name="queryCerlCTAS">
      <xsl:param name="id"/>
      <xsl:if test="string-length($id) &lt; 1">
         <xsl:message>No valid ID given!</xsl:message>
      </xsl:if>
      <xsl:variable name="queryString"
                    select="concat($queryPrefix, encode-for-uri(concat($idPrefix,$id)))"/>
      <xsl:variable name="queryURL" select="concat($urlPrefix, $queryString)"/>
      <xsl:message>
            Query URL: <xsl:value-of select="$queryURL"/>
      </xsl:message>
      <xsl:variable name="cerlEntry" select="document($queryURL)//srw:record"/>
      <xsl:copy-of select="$cerlEntry"/>
   </xsl:template>
   <xsl:template name="getPersVariants">
      <xsl:param name="element" select="string('addName')"/>
      <xsl:param name="namespace" select="string('http://www.tei-c.org/ns/1.0')"/>
      <xsl:param name="node"/>
      <xsl:param name="display-attribute-name" select="false()"/>
      <xsl:param name="display-attribute-value" select="false()"/>
      <xsl:variable name="cerlEntry">
         <xsl:choose>
            <xsl:when test="empty($node)">
               <xsl:message terminate="yes">
                        No valid Cerl Record given!
                    </xsl:message>
            </xsl:when>
            <xsl:when test="count($node//ctas:record/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:call-template name="queryCerlCTAS">
                  <xsl:with-param name="id" select="$node"/>
               </xsl:call-template>
            </xsl:when>
                <!--
                    Wrong record format given 
                --><xsl:when test="$node//marcxml:record">
               <xsl:call-template name="queryCerlCTAS">
                  <xsl:with-param name="id" select="$node//marcxml:controlfield/text()"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="string($display-attribute-name) != string(false()) and string($display-attribute-value) != string(false())">
            <xsl:element name="{$element}" namespace="{$namespace}">
               <xsl:attribute name="{$display-attribute-name}">
                  <xsl:value-of select="$display-attribute-value"/>
               </xsl:attribute>
               <xsl:value-of select="$cerlEntry//ctas:info/ctas:display/text()"/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="{$element}" namespace="{$namespace}">
               <xsl:value-of select="$cerlEntry//ctas:info/ctas:display/text()"/>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="$cerlEntry//ctas:headingForm[@name = 'full']">
         <xsl:element name="{$element}" namespace="{$namespace}">
            <xsl:value-of select="."/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="$cerlEntry//ctas:variantForm[@name != 'inverted']">
         <xsl:element name="{$element}" namespace="{$namespace}">
            <xsl:value-of select="."/>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="getPND">
      <xsl:param name="node"/>
      <xsl:variable name="cerlEntry">
         <xsl:choose>
            <xsl:when test="count($node//ctas:record/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:call-template name="queryCerlCTAS">
                  <xsl:with-param name="id" select="$node"/>
               </xsl:call-template>
            </xsl:when>
                <!--
                   Wrong record format given 
                --><xsl:when test="$node//marcxml:record">
               <xsl:call-template name="queryCerlCTAS">
                  <xsl:with-param name="id" select="$node"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$cerlEntry//ctas:identifier[@type = 'other'][@source='DE:PND']"/>
   </xsl:template>
   <xsl:template name="getName">
      <xsl:param name="node"/>
      <xsl:variable name="cerlEntry">
         <xsl:choose>
            <xsl:when test="count($node//ctas:record/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:call-template name="queryCerlCTAS">
                  <xsl:with-param name="id" select="$node"/>
               </xsl:call-template>
            </xsl:when>
                <!--
                    Wrong record format given 
                --><xsl:when test="$node//marcxml:record">
               <xsl:call-template name="queryCerlCTAS">
                  <xsl:with-param name="id" select="$node"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$cerlEntry//ctas:headingForm[@name = 'full'][1] != ''">
            <xsl:value-of select="$cerlEntry//ctas:headingForm[@name = 'full']"/>
         </xsl:when>
         <xsl:when test="$cerlEntry//ctas:headingForm[@name = 'single'][1] != ''">
            <xsl:value-of select="$cerlEntry//ctas:headingForm[@name = 'single']"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
