<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 9, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="ropen:concat-path" as="xs:anyURI">
        <xsl:param name="path" as="xs:string"/>
        <xsl:param name="filename" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="ends-with($path, '/') or starts-with($filename, '/')">
                <xsl:value-of select="concat($path, $filename)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($path, '/', $filename)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>