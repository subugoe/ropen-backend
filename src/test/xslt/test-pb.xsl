<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:TEI="http://www.tei-c.org/ns/1.0"
    xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:include href="../../main/xslt/transformations/lib/a18.xsl"/>
    <xsl:param name="test-file" select="'../xml/sample-pb.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="content">
            <xsl:choose>
                <xsl:when test="$test-file != ''">
                    <xsl:copy-of select="document($test-file)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$content//TEI:pb">
            <xsl:variable name="file-name" select="concat('result-fragment-', position(), '.xml')"/>
            <xsl:result-document href="{$file-name}">
                <xsl:copy-of select="a18:chunk(./ancestor::TEI:body/child::*[1], ., //TEI:body)"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
