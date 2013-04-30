<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tgn="http://textgrid.info/namespaces/vocabularies/tgn"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
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
   <xsl:variable name="gettyQueryUrl"
                 select="'http://textgridlab.org/tgnsearch/tgnquery.xql?id='"/>
   <xsl:variable name="gettyUrl"
                 select="'http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid='"/>
   <xsl:variable name="getty-id-prefix" select="'#GettyID:'"/>
   <xsl:template name="queryGettyRef">
      <xsl:param name="ref"/>
      <xsl:variable name="gettyID" select="translate($ref, $getty-id-prefix, '')"/>
      <xsl:call-template name="queryGetty">
         <xsl:with-param name="id">
            <xsl:value-of select="$gettyID"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="queryGetty">
      <xsl:param name="id"/>
      <xsl:if test="string-length($id) &lt; 1">
         <xsl:message>No valid ID given!</xsl:message>
      </xsl:if>
      <xsl:variable name="gettyEntry" select="document(concat($gettyQueryUrl, $id))"/>
      <xsl:copy-of select="$gettyEntry"/>
   </xsl:template>
   <xsl:template name="getGettyURL">
      <xsl:param name="id"/>
      <xsl:choose>
         <xsl:when test="$id != '' and $id != '#'">
            <xsl:value-of select="concat($gettyUrl, $id)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="''"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="getGettyQueryURL">
      <xsl:param name="id"/>
      <xsl:choose>
         <xsl:when test="$id != '' and $id != '#'">
            <xsl:value-of select="concat($gettyQueryUrl, $id)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="''"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="getLat">
      <xsl:param name="node"/>
      <xsl:variable name="gettyEntry">
         <xsl:choose>
            <xsl:when test="count($node/tgn:response/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:message terminate="yes">TODO: Fix the invocation of "gettyQuery"</xsl:message>
                    <!--
                    <xsl:call-template name="queryGetty">
                        <xsl:with-param name="ref" select="$node"/>
                    </xsl:call-template>
                    --></xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$gettyEntry/tgn:response/tgn:Subject/tgn:Coordinates/tgn:Standard/tgn:Latitude/tgn:Decimal"/>
   </xsl:template>
   <xsl:template name="getLon">
      <xsl:param name="node"/>
      <xsl:variable name="gettyEntry">
         <xsl:choose>
            <xsl:when test="count($node/tgn:response/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:message terminate="yes">TODO: Fix the incocation of "gettyQuery"</xsl:message>
                    <!--
                    <xsl:call-template name="queryGetty">
                        <xsl:with-param name="ref" select="$node"/>
                    </xsl:call-template>
                    --></xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$gettyEntry/tgn:response/tgn:Subject/tgn:Coordinates/tgn:Standard/tgn:Longitude/tgn:Decimal"/>
   </xsl:template>
   <xsl:template name="getDesc">
      <xsl:param name="node"/>
      <xsl:variable name="gettyEntry">
         <xsl:choose>
            <xsl:when test="count($node/tgn:response/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:message terminate="yes">TODO: Fix the incocation of "gettyQuery"</xsl:message>
                    <!--
                    <xsl:call-template name="queryGetty">
                        <xsl:with-param name="ref" select="$node"/>
                    </xsl:call-template>
                    --></xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$gettyEntry/tgn:response/tgn:Subject/tgn:Descriptive_Note/tgn:Note_Text"/>
   </xsl:template>
   <xsl:template name="hasCoord">
      <xsl:param name="node"/>
      <xsl:variable name="gettyEntry">
         <xsl:choose>
            <xsl:when test="count($node/tgn:response/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:message terminate="yes">TODO: Fix the incocation of "gettyQuery"</xsl:message>
                    <!--
                    <xsl:call-template name="queryGetty">
                        <xsl:with-param name="ref" select="$node"/>
                    </xsl:call-template>
                    --></xsl:when>
            <xsl:otherwise>
               <xsl:message> Wrong datatype given, Getty ID or response node expected
                    </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="$gettyEntry/tgn:response/tgn:Subject/tgn:Coordinates">
         <xsl:value-of select="true()"/>
      </xsl:if>
      <xsl:value-of select="false()"/>
   </xsl:template>
   <xsl:template name="getPlaceVariants">
      <xsl:param name="node"/>
      <xsl:param name="element" select="string('addName')"/>
      <xsl:param name="namespace" select="string('http://www.tei-c.org/ns/1.0')"/>
      <xsl:param name="display-attribute-name" select="false()"/>
      <xsl:param name="display-attribute-value" select="false()"/>
      <xsl:variable name="gettyEntry">
         <xsl:choose>
            <xsl:when test="count($node/tgn:response/descendant::*) &gt; 3">
               <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node = text()">
               <xsl:message terminate="yes">TODO: Fix the incocation of "gettyQuery"</xsl:message>
                    <!--
                    <xsl:call-template name="queryGetty">
                        <xsl:with-param name="ref" select="$node"/>
                    </xsl:call-template>
                    --></xsl:when>
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
               <xsl:value-of select="$gettyEntry//tgn:Preferred_Term/tgn:Term_Text/text()"/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="{$element}" namespace="{$namespace}">
               <xsl:value-of select="$gettyEntry//tgn:Preferred_Term/tgn:Term_Text/text()"/>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$gettyEntry/tgn:response/tgn:Subject/tgn:Terms/tgn:Preferred_Term/tgn:Term_Text/text()">
         <xsl:element name="{$element}" namespace="{$namespace}">
            <xsl:value-of select="$gettyEntry/tgn:response/tgn:Subject/tgn:Terms/tgn:Preferred_Term/tgn:Term_Text"/>
         </xsl:element>
      </xsl:if>
      <xsl:for-each select="$gettyEntry/tgn:response/tgn:Subject/tgn:Terms/tgn:Non-Preferred_Term">
         <xsl:element name="{$element}" namespace="{$namespace}">
            <xsl:value-of select="./tgn:Term_Text"/>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>
