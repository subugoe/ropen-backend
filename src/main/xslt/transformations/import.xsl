<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd ropen" version="2.0">
    <!-- Imports -->
    <xsl:import href="./metadata-enrichment.xsl"/>
    <xsl:import href="./mets.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jul 26, 2013</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <!-- Public params -->
    <xsl:param name="collection"/>
    <xsl:param name="mets-collection"/>
    <xsl:param name="tei-enriched-collection"/>

    <xsl:template match="/">
        <!-- Loop over the input collection -->
        <table>
            <thead>
                <td>Input path</td>
                <td>Filename</td>
                <td>Enriched</td>
                <td>METS</td>
            </thead>

            <tr>
                <xsl:for-each select="collection(concat($collection, '/?select=*.xml'))">
                    <td>
                        <xsl:value-of select="document-uri(.)"/>
                    </td>
                    <xsl:variable name="in-file">
                        <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                    </xsl:variable>

                    <!-- Contructed file names -->
                    <xsl:variable name="mets-file" select="ropen:concat-path($mets-collection, $in-file)" as="xs:anyURI"/>
                    <xsl:variable name="tei-enriched-file" select="ropen:concat-path($tei-enriched-collection, $in-file)" as="xs:anyURI"/>
                    <td>
                        <xsl:value-of select="$in-file"/>
                    </td>
                    <td>
                        <span>
                            <xsl:variable name="success" as="xs:boolean">
                                <xsl:call-template name="ropen:enrich-tei">
                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                    <xsl:with-param name="output" select="$mets-file"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$success">
                                    <xsl:attribute name="style">
                                        <xsl:text>color: green;</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="style">
                                        <xsl:text>color: red;</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="$mets-file"/>
                        </span>
                    </td>
                    <td>
                        <span>
                            <xsl:variable name="success" as="xs:boolean">
                                <xsl:call-template name="ropen:enrich-tei">
                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                    <xsl:with-param name="output" select="$tei-enriched-file"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$success">
                                    <xsl:attribute name="style">
                                        <xsl:text>color: green;</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="style">
                                        <xsl:text>color: red;</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="$tei-enriched-file"/>
                        </span>
                        <xsl:value-of select="$tei-enriched-file"/>
                    </td>
                </xsl:for-each>
            </tr>
        </table>
    </xsl:template>

    <xsl:template match="text()"/>

    <xsl:template name="ropen:create-mets" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:result-document href="{$output}">
            <xsl:apply-templates select="document($input)" mode="mets"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>

    <xsl:template name="ropen:enrich-tei" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:result-document href="{$output}">
            <xsl:apply-templates select="document($input)" mode="enrichment"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>

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
