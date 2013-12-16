<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:TEI="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd TEI" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 29, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:param name="input-collection"/>
    <xsl:param name="output-collection"/>
    
    <xsl:include href="TEI2XHTML.xsl"/>

    <xsl:template match="/" priority="2">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Entitätenstatistik</title>
            </head>
            <body>
                <table>
                    <thead>
                        <tr>
                            <td>Input folder</td>
                            <td>Input file</td>
                            <td>Output folder</td>
                            <td>Output file</td>
                        </tr>
                    </thead>
                    <!-- Loop over the input collection -->
                    <xsl:for-each select="collection(concat($input-collection, '/?select=*.xml'))">
                        <tr>
                            <xsl:variable name="input-file" select="tokenize(document-uri(.), '/')[last()]"/>
                            <!-- Contructed file names -->
                            <xsl:variable name="output-file" select="concat($output-collection, $input-file)"/>
                            <xsl:result-document href="{$output-file}" method="xml">
                                <xsl:apply-templates select="document(document-uri(.))//TEI:teiHeader"/>
                                <xsl:message><xsl:value-of select="$output-file"/> written.</xsl:message>
                            </xsl:result-document>
                            <td>
                                <xsl:value-of select="$input-collection"/>
                            </td>
                            <td>
                                <xsl:value-of select="$input-file"/>
                            </td>
                            <td>
                                <xsl:value-of select="$output-collection"/>
                            </td>
                            <td>
                                <xsl:value-of select="$output-file"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
