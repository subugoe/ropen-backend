<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:string="http://archaeo18.sub.uni-goettingen.de/exist/string"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs xd"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Jul 25, 2013</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:function name="string:match-sequence-any" as="xs:boolean">
      <xsl:param name="input" as="xs:string"/>
      <xsl:param name="patterns" as="xs:string*"/>
      <xsl:choose>
         <xsl:when test="for $p in $patterns return matches($input, $p)">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="false()"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="string:replace-sequence" as="xs:string?">
      <xsl:param name="input" as="xs:string"/>
      <xsl:param name="patterns" as="xs:string*"/>
      <xsl:choose>
         <xsl:when test="count($patterns) &gt; 0">
            <xsl:copy-of select="string:replace-sequence(replace($input, $patterns[1], ''), $patterns[position() &gt; 1])"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$input"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="string:find-first-match" as="xs:string">
      <xsl:param name="input" as="xs:string"/>
      <xsl:param name="patterns" as="element()"/>
      <xsl:variable name="results">
         <xsl:for-each select="$patterns//*/@pattern">
            <xsl:if test="matches($input, .)">
               <xsl:value-of select="$patterns//*[@pattern = .]/@match"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="not(empty(distinct-values($results[not(. = '')])))">
            <xsl:value-of select="distinct-values($results[not(. = '')])[1]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="''"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="string:find-match" as="xs:string*">
      <xsl:param name="input" as="xs:string"/>
      <xsl:param name="patterns" as="element()"/>
      <xsl:variable name="results">
         <xsl:for-each select="$patterns//*/@pattern">
            <xsl:if test="matches($input, .)">
               <xsl:value-of select="$patterns//*[@pattern = .]/@match"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="distinct-values($results[not(. = '')])"/>
   </xsl:function>
   <xsl:function name="string:word-count" as="xs:string">
      <xsl:param name="arg" as="xs:string"/>
      <xsl:value-of select="count(tokenize($arg, '\W+')[. != ''])"/>
   </xsl:function>
   <xsl:function name="string:trim" as="xs:string">
      <xsl:param name="arg" as="xs:string"/>
      <xsl:value-of select="replace(replace($arg,'\s+$',''),'^\s+','')"/>
   </xsl:function>
</xsl:stylesheet>
