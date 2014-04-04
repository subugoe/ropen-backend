<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    xmlns:TEI="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd"
    version="2.0">
    <xsl:include href="./lib/ropen.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 7, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Public params -->
    <xsl:param name="collection-base"/>
    <xsl:param name="mets-collection"/>
    <xsl:param name="tei-enriched-collection"/>
    <xsl:param name="tei-collection"/>
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
            <xsl:for-each select="collection(concat($tei-collection, '/?select=*.xml'))">
                <xsl:variable name="id" select="replace($doc, '.xml', '')" as="xs:string"></xsl:variable>
                <xsl:variable name="filename" select="document(.)"></xsl:variable>
                <doc>
                    <id>{$id}</id>
                    <title>
                        <xsl:value-of select="./TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]/text()"></xsl:value-of>
                    </title>
                    <titleShort>
                        <xsl:value-of select="./TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[@type = 'display']/text()"></xsl:value-of>
                        {$title-short}</titleShort>
                    <preview><xsl:value-of select=""></xsl:value-of>
                        {$preview}</preview>
                    <tei><xsl:value-of select=""></xsl:value-of>
                        {$tei-location}</tei>
                    <teiEnriched><xsl:value-of select=""></xsl:value-of>
                        {$tei-enriched-location}</teiEnriched>
                    <mets><xsl:value-of select=""></xsl:value-of>
                        {$metsFile}</mets>
                    <pageCount><xsl:value-of select="count(.//TEI:pb)+1"></xsl:value-of>
                        {$pageCount}</pageCount>
                </doc>
<!-- 
                            let $id := replace($doc, '.xml', '')
            let $tei-enriched-location := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $id, '-enriched.xml')
            let $tei-enriched := doc($tei-enriched-location)
            let $title := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]/text()
            let $origDate := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:sourceDesc/TEI:msDesc/TEI:history/TEI:origin/TEI:origDate/text()
            let $title-short := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[@type = 'display']/text()
            let $metsFile := concat($archeao18conf:dataBase, $archeao18conf:metsPrefix, $id, '.mets.xml')
            let $preview := data(doc($metsFile)//METS:fileGrp[@USE = 'MIN']//METS:file[1]/METS:FLocat/@xlink:href)        
            let $tei-location := concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $id, '.xml')
            let $pageCount := count($tei-enriched//TEI:pb)
                -->
            </xsl:for-each>
        </docs>
    </xsl:template>
</xsl:stylesheet>
