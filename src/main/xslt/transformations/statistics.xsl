<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <!-- Public params -->
    <xsl:param name="collection"/>

    <xsl:template match="/">

        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Entitätenstatistik</title>
            </head>
            <body>
                <table>
                    <thead>
                        <tr>
                            <td rowspan="3">Dokument</td>
                            <td colspan="12">Entität</td>
                        </tr>
                        <tr>
                            <td/>
                            <td colspan="3">Person</td>
                            <td colspan="3">Ort</td>
                            <td colspan="3">Werk</td>
                            <td colspan="3">Artefakt</td>
                        </tr>
                        <tr>
                            <td/>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="collection(concat($collection, '/?select=*.xml'))">
                            <tr>
                                <!-- Loop over the input collection -->
                                <xsl:variable name="in-file">
                                    <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                                </xsl:variable>
                                <!-- Contructed file names -->
                                <td>
                                    <xsl:value-of select="$in-file"/>
                                </td>
                                <!-- Person -->
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:persName[@ref and @ref != ''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:persName[not(@ref) or @ref=''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:persName)"/>
                                </td>
                                <!-- Place -->
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:placeName[@ref and @ref != ''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:placeName[not(@ref) or @ref=''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:placeName)"/>
                                </td>
                                <!-- Work -->
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:bibl[descendant::TEI:taget/@ref and descendant::TEI:taget/@ref != ''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:bibl[not(descendant::TEI:taget/@ref) or descendant::TEI:taget/@ref=''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:bibl)"/>
                                </td>
                                <!-- Artifact -->
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:term[@ref and @ref != ''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:term[not(@ref) or @ref=''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:term)"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                        <tr>
                            <td>Insgesamt</td>
                            <!-- Person -->
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:persName[@ref and @ref != ''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:persName[not(@ref) or @ref=''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:persName)"/>
                            </td>
                            <!-- Place -->
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:placeName[@ref and @ref != ''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:placeName[not(@ref) or @ref=''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:placeName)"/>
                            </td>
                            <!-- Work -->
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl[descendant::TEI:taget/@ref and descendant::TEI:taget/@ref != ''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl[not(descendant::TEI:taget/@ref) or descendant::TEI:taget/@ref=''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl)"/>
                            </td>
                            <!-- Artifact -->
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:term[@ref and @ref != ''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:term[not(@ref) or @ref=''])"/>
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:term)"/>
                            </td>

                        </tr>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
