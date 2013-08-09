<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 7, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Public params -->
    <xsl:param name="collection"/>
    <xsl:param name="mets-collection"/>
    <xsl:param name="tei-enriched-collection"/>
    <xsl:param name="doc"/>
    <xsl:template match="/">
        <!-- Loop over the input collection -->
        <docs>
            <xsl:variable name="doc" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$doc != ''">
                        <xsl:value-of select="concat($doc, '.xml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'.xml'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="collection(concat($collection, '/?select=*.xml'))">
                <doc>
                    <id>{$id}</id>
                    <title>{$title}</title>
                    <titleShort>{$title-short}</titleShort>
                    <preview>{$preview}</preview>
                    <tei>{$tei-location}</tei>
                    <teiEnriched>{$tei-enriched-location}</teiEnriched>
                    <mets>{$metsFile}</mets>
                    <pageCount>{$pageCount}</pageCount>
                </doc>

            </xsl:for-each>
        </docs>
    </xsl:template>
</xsl:stylesheet>
