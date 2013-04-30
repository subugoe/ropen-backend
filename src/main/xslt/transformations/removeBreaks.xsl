<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                version="1.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Aug 4, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="removePb" select="true()"/>
   <xsl:param name="removeAddName" select="true()"/>
   <xsl:variable name="debug" select="false()"/>
   <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no"/>
   <xsl:strip-space elements="TEI:p"/>
   <xsl:template match="/">
      <xsl:choose>
         <xsl:when test="/TEI:TEI/TEI:teiHeader">
            <TEI:TEI>
               <xsl:copy-of select="//TEI:teiHeader"/>
               <TEI:text>
                  <xsl:apply-templates select="/TEI:TEI/TEI:text"/>
               </TEI:text>
            </TEI:TEI>
         </xsl:when>
            <!-- This will be used if in document fragment mode --><xsl:otherwise>
            <xsl:apply-templates select="//TEI:text"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="TEI:pb">
      <xsl:if test="$removePb = false()">
         <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="TEI:lb">
      <xsl:if test="$debug = true()">
         <xsl:variable name="precedingText" select="string(./preceding-sibling::text()[1])"/>
         <xsl:if test="substring($precedingText, string-length($precedingText), 1) = '-'">
            <xsl:message>- found!</xsl:message>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   <xsl:template match="text()">
      <xsl:choose>
         <xsl:when test="local-name(./following-sibling::node()[1]) = 'lb'">
            <xsl:choose>
               <xsl:when test="substring(., string-length(.), 1) = '-'">
                  <xsl:value-of select="substring(., 0, string-length(.) -1)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="."/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="TEI:addName">
      <xsl:if test="$removeAddName = false()">
         <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="*">
      <xsl:element name="{name()}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
