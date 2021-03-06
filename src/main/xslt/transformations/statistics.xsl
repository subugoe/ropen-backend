<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd TEI" version="2.0">
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
                <style type="text/css">
                    body{
                        font-family:verdana, arial, sans-serif;
                        font-size:11px;
                    }
                    table,
                    thead,
                    td{
                        border:1px solid #000000;
                        border-collapse:collapse;
                        border-spacing:0;
                    }
                    thead tr td{
                        background:#F0F0F0;
                        text-align:center;
                        font-weight:bold;
                        font-size:13px;
                    }
                    .unique{
                        background:#707070;
                    }
                    .sum{
                        background:#D8D8D8;
                    }</style>
            </head>
            <body>
                <table>
                    <thead>
                        <tr>
                            <td rowspan="3">Dokument</td>
                            <td colspan="17">Entität</td>
                        </tr>
                        <tr>
                            <td colspan="4">Person</td>
                            <td colspan="4">Ort</td>
                            <td colspan="4">Werk</td>
                            <td colspan="4">Artefakt</td>
                            <td rowspan="2">Insgesamt</td>
                        </tr>
                        <tr>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Eindeutig</td>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Eindeutig</td>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Eindeutig</td>
                            <td>Ausgezeichnet</td>
                            <td>Nicht ausgezeichnet</td>
                            <td>Insgesamt</td>
                            <td>Eindeutig</td>
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
                                <td class="sum">
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:persName)"/>
                                </td>
                                <td class="unique">
                                    <xsl:value-of select="count(distinct-values(document(document-uri(.))//TEI:persName/@ref))"/>
                                </td>
                                <!-- Place -->
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:placeName[@ref and @ref != ''])"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:placeName[not(@ref) or @ref=''])"/>
                                </td>
                                <td class="sum">
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:placeName)"/>
                                </td>
                                <td class="unique">
                                    <xsl:value-of select="count(distinct-values(document(document-uri(.))//TEI:placeName/@ref))"/>
                                </td>
                                <!-- Work -->
                                <td>
                                    <xsl:value-of
                                        select="count(document(document-uri(.))//TEI:bibl[descendant::TEI:ref/@target and (descendant::TEI:ref/@target != '' or descendant::TEI:ref/@target != '#')])"/>
                                </td>
                                <td>
                                    <xsl:value-of
                                        select="count(document(document-uri(.))//TEI:bibl[not(descendant::TEI:ref/@target) or descendant::TEI:ref/@target = '' or descendant::TEI:ref/@target = '#'])"/>
                                </td>
                                <td class="sum">
                                    <xsl:value-of select="count(document(document-uri(.))//TEI:bibl)"/>
                                </td>
                                <td class="unique">
                                    <xsl:value-of select="count(distinct-values(document(document-uri(.))//TEI:bibl//TEI:ref/@target))"/>
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
                                <td class="unique">
                                    <xsl:value-of select="count(distinct-values(document(document-uri(.))//TEI:term/@ref))"/>
                                </td>
                                <!-- All -->
                                <td class="sum">
                                    <xsl:value-of
                                        select="count(count(document(document-uri(.))//TEI:term)) + count(document(document-uri(.))//TEI:bibl) + count(document(document-uri(.))//TEI:placeName) + count(document(document-uri(.))//TEI:persName)"
                                    />
                                </td>
                            </tr>
                        </xsl:for-each>
                        <tr class="sum">
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
                            <td class="unique">
                                <xsl:value-of select="count(distinct-values(collection(concat($collection, '/?select=*.xml'))//TEI:persName/@ref))"/>
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
                            <td class="unique">
                                <xsl:value-of select="count(distinct-values(collection(concat($collection, '/?select=*.xml'))//TEI:placeName/@ref))"/>
                            </td>
                            <!-- Work -->
                            <td>
                                <xsl:value-of
                                    select="count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl[descendant::TEI:ref/@target and (descendant::TEI:ref/@target != '' or descendant::TEI:ref/@target != '#')])"
                                />
                            </td>
                            <td>
                                <xsl:value-of
                                    select="count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl[not(descendant::TEI:ref/@target) or descendant::TEI:ref/@target = '' or descendant::TEI:ref/@target = '#'])"
                                />
                            </td>
                            <td>
                                <xsl:value-of select="count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl)"/>
                            </td>
                            <td class="unique">
                                <xsl:value-of select="count(distinct-values(collection(concat($collection, '/?select=*.xml'))//TEI:bibl//TEI:ref/@target))"/>
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
                            <td class="unique">
                                <xsl:value-of select="count(distinct-values(collection(concat($collection, '/?select=*.xml'))//TEI:term/@ref))"/>
                            </td>
                            <!-- All -->
                            <td>
                                <xsl:value-of
                                    select="count(collection(concat($collection, '/?select=*.xml'))//TEI:term) + count(collection(concat($collection, '/?select=*.xml'))//TEI:bibl) + count(collection(concat($collection, '/?select=*.xml'))//TEI:placeName) + count(collection(concat($collection, '/?select=*.xml'))//TEI:persName)"
                                />
                            </td>
                        </tr>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
