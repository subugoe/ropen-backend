<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sub="http://sub.uni-goettingen.de/xslt/functions/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xd a18"
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
    <!--
    <xsl:param name="fatal-param" select="false()"/>
    <xsl:variable name="fatal" select="if ($fatal-param castable as xs:boolean) then xs:boolean($fatal-param) else false()" as="xs:boolean"/>
    <xsl:variable name="terminate" as="xs:string">
        <xsl:choose>
            <xsl:when test="$fatal = true()">
                <xsl:value-of select="'yes'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'no'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    --><xsl:variable name="local-terminate" as="xs:string" select="'yes'"/>
   <xsl:variable name="prefixes">
      <a18:prefixes>
         <a18:prefix name="getty"
                     uri="http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid="
                     pattern="GettyID:(\d{{7,8}})"
                     start="GettyID"/>
         <a18:prefix name="cerl"
                     uri="http://thesaurus.cerl.org/cgi-bin/record.pl?rid="
                     pattern="CerlID:(cn[pi]\d{{8,9}})"
                     start="CerlID"/>
         <a18:prefix name="census"
                     uri="http://census.bbaw.de/easydb/censusID="
                     pattern="CensusID:(\d{{6,9}})"
                     start="CensusID"/>
         <a18:prefix name="http" uri="http" pattern="http(s?://.*)" start="http"/>
         <a18:prefix name="page" uri="#" pattern="(p.+)" start="p"/>
            <!-- This is needed for malformed URIs --><a18:prefix name="" uri="" pattern="(.+)" start=""/>
      </a18:prefixes>
   </xsl:variable>
   <xsl:variable name="dnbURL" select="'http://d-nb.info/gnd/'" as="xs:string"/>
   <xsl:function name="a18:resolve-id" as="xs:string">
        <!-- See XQuery implementation in modules/archaeo18lib.xq --><xsl:param name="id" as="xs:string"/>
        <!-- Clean up leading # --><xsl:variable name="identifier"
                    as="xs:string"
                    select="replace($id, '^#(.*)$', '$1')"/>
      <xsl:variable name="name" as="xs:string">
         <xsl:choose>
                <!-- URIs with schema prefix --><xsl:when test="contains($identifier, ':')">
               <xsl:value-of select="$prefixes//a18:prefix[@start = substring-before($identifier, ':')]/@name"/>
            </xsl:when>
                <!-- local anchors --><xsl:when test="matches($id, '#[\w-]')">
               <xsl:value-of select="$prefixes//a18:prefix[@start = replace($identifier, '([A-Za-z]+).*', '$1')]/@name"/>
            </xsl:when>
            <xsl:otherwise>
                    <!-- This stylesheet will fail here, since a empty result for this variable will fail later on when it's given to the function. --><xsl:message terminate="{$local-terminate}">Can't extract prefix for id <xsl:value-of select="$id"/>
               </xsl:message>
               <xsl:value-of select="$prefixes//a18:prefix[@start = '']/@name"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="concat($prefixes//a18:prefix[@name = $name]/@uri, replace($identifier, $prefixes//a18:prefix[@name = $name]/@pattern, '$1'))"/>
   </xsl:function>
   <xsl:function name="a18:normalize-space">
      <xsl:param name="str" as="xs:string"/>
      <xsl:choose>
            <!-- TODO: no space if the next element is a lb - and contains($str, '
') --><xsl:when test="matches($str, '^\s*[\r\n]\s+$')">
            <xsl:value-of select="' '"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$str"/>
                <!--
                <xsl:value-of select="normalize-space($str)"></xsl:value-of>
           --></xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="a18:chunk">
      <xsl:param name="ms1" as="element()"/>
      <xsl:param name="ms2" as="element()"/>
      <xsl:param name="node" as="node()"/>
      <xsl:choose>
         <xsl:when test="$node instance of element()">
            <xsl:choose>
               <xsl:when test="$node is $ms1">
                  <xsl:copy-of select="$node"/>
               </xsl:when>
               <xsl:when test="some $n in $node/descendant::* satisfies ($n is $ms1 or $n is $ms2)">
                  <xsl:element name="{local-name($node)}" namespace="{namespace-uri($node)}">
                     <xsl:for-each select="$node/node() | $node/@*">
                        <xsl:copy-of select="a18:chunk($ms1, $ms2, .)"/>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="$node &gt;&gt; $ms1 and $node &lt;&lt; $ms2">
                  <xsl:copy-of select="$node"/>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$node instance of attribute()">
            <xsl:copy-of select="$node"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$node &gt;&gt; $ms1 and $node &lt;&lt; $ms2">
               <xsl:copy-of select="$node"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>
