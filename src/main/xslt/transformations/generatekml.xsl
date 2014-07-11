<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:TEI="http://www.tei-c.org/ns/1.0"
    xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    exclude-result-prefixes="xs xd a18 exist xlink xhtml ropen" version="2.0">

    <xsl:param name="input-collection" select="''" as="xs:string"/>
    <xsl:param name="output-collection" select="''" as="xs:string"/>
    <xsl:param name="mode" select="'kml'" as="xs:string"/>
    
    <xsl:include href="./gettyQuery.xsl"/>
    <xsl:include href="TEI2XHTML.xsl"/>
    <xsl:include href="./lib/ropen.xsl"/>
    
    <xsl:template match="/"  priority="10">
        <xsl:message>Document is: <xsl:value-of select="document-uri(root(.))"/></xsl:message>
        <xsl:variable name="suffix">
            <xsl:choose>
                <xsl:when test="$mode = 'kml'">
                    <xsl:value-of select="'.kml'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="page" select="'-0'" />
        
        <xsl:for-each select="collection(concat($input-collection, '/?select=*.xml'))">
            <xsl:variable name="in-file" select="ropen:uri-to-name(replace(tokenize(document-uri(.), '/')[last()], '.tei', ''))" as="xs:string"/>
            <xsl:variable name="outfile" select="ropen:concat-path($output-collection, concat($in-file, $page, $suffix))" as="xs:anyURI"/>    
            <xsl:message>Generating kml file <xsl:value-of select="$outfile"/> </xsl:message>
            <xsl:choose>
                <xsl:when test="$mode = 'kml'">
                     <xsl:result-document href="{$outfile}" encoding="UTF-8">
                    <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:kml="http://www.opengis.net/kml/2.2">
                        <Document>
                            <xsl:apply-templates select=".//TEI:placeName" mode="kml" />
                        </Document>
                    </kml>
                     </xsl:result-document>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>  
    </xsl:template>
    
</xsl:stylesheet>
