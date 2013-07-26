<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:TEI="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xs"
                version="2.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Apr 21, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:output method="xml" indent="yes" name="xml"/>
   <xsl:include href="./lib/a18.xsl"/>
   <xsl:param name="startParam"/>
   <xsl:param name="endParam"/>
   <xsl:variable name="start"
                 select="if ($startParam castable as xs:integer) then xs:integer($startParam) else 0"/>
   <xsl:variable name="end"
                 select="if ($endParam castable as xs:integer) then xs:integer($endParam) else 0"/>
    <!-- TODO: Create a function for this --><xsl:template match="/">
      <xsl:choose>
         <xsl:when test="$start != 0 and $end != 0">
            <xsl:copy-of select="a18:chunk(//TEI:pb[$start], //TEI:pb[$end], .)"/>
         </xsl:when>
         <xsl:when test="$start != 0 and $end = 0">
            <xsl:copy-of select="a18:chunk(//TEI:pb[$start], //TEI:pb[last()], .)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
    
    
    <!--
    <xsl:variable name="cutElement">
        <xsl:text>p</xsl:text>
    </xsl:variable>
    -->
    <!--
    <xsl:template match="/">
        <xsl:for-each select="//TEI:p">

            <xsl:variable name="filename">
                <xsl:text>./out/</xsl:text>
                <xsl:number format="00000001" value="count(preceding::TEI:p) + 1"/>
                <xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:result-document href="{$filename}" format="xml">
                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader/>
                    <text>
                        <body>
                            <p>
                                <xsl:for-each select="@*">
                                    <xsl:attribute name="{name()}">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                </xsl:for-each>
                                <xsl:apply-templates/>
                            </p>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="*" priority="-1">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:attribute name="{name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    --></xsl:stylesheet>
