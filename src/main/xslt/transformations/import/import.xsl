<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:err="http://www.w3.org/2005/xqt-errors" xmlns:METS="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="err METS xs xd TEI a18 ropen xlink xhtml" version="2.0">
    <!-- Imports -->
    <xsl:import href="../metadata-enrichment.xsl"/>
    <xsl:import href="../mets-2.0.xsl"/>
    <xsl:import href="../structure-extractor.xsl"/>
    <xsl:include href="../lib/ropen.xsl"/>
    <xsl:include href="../lib/a18.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jul 26, 2013</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="no"/>
    <!-- Public params -->
    <!-- Input collection (TEI files) - this isn't optional -->
    <xsl:param name="collection" as="xs:string"/>
    <!-- Output METS files -->
    <xsl:param name="mets-collection" as="xs:string" select="''"/>
    <!-- Collection for enriched TEIs -->
    <xsl:param name="tei-enriched-collection" as="xs:string" select="''"/>
    <!-- File for the document listing -->
    <xsl:param name="document-listing-file" as="xs:string" select="''"/>
    <!-- Collection XHTML files containing the document structure -->
    <xsl:param name="structure-collection" as="xs:string" select="''"/>
    <!-- Prefix to replace -->
    <xsl:param name="replace-prefix" as="xs:string" select="''"/>
    <!-- Prefix to prepend -->
    <xsl:param name="prepend-prefix" as="xs:string" select="''"/>
    <!-- Collection XHTML files containing the whole document -->
    <xsl:param name="xhtml-collection" as="xs:string" select="''"/>
    <!-- Collection XHTML files containing the header -->
    <xsl:param name="xhtml-header-collection" as="xs:string" select="''"/>
    <!-- TODO: Make this work for METS -->
    <xsl:param name="url-prefix" as="xs:string" select="''"/>
    <!-- 
         This avoids checks if files exist, since some versions of Saxon reading
         a file written during a transformation consider this an error while 
         other versions only generate a warning...
         Error XTRE1500
    
    <xsl:param name="check-files" as="xs:boolean" select="false()"/>

        This feature has been disabled since Saxon seems to be problematic here,
        jus add calls to ropen:file-exists($file) at the appropriate places.
    -->
    <xsl:param name="output-param" select="'xhtml'"/>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head/>
            <body>
                <xsl:if test="$collection != '' ">
                    <table>
                        <thead>
                            <td>Input path</td>
                            <td>Filename</td>
                            <xsl:if test="$tei-enriched-collection != ''">
                                <td>Enriched</td>
                            </xsl:if>
                            <xsl:if test="$mets-collection != ''">
                                <td>METS</td>
                            </xsl:if>
                            <xsl:if test="$structure-collection != ''">
                                <td>XHTML Structure</td>
                            </xsl:if>
                            <xsl:if test="$xhtml-collection != ''">
                                <td>XHTML Content</td>
                            </xsl:if>
                            <xsl:if test="$xhtml-header-collection != ''">
                                <td>XHTML Header</td>
                            </xsl:if>
                        </thead>

                        <tr>
                            <!-- Loop over the input collection -->
                            <xsl:for-each select="collection(concat($collection, '/?select=*.xml'))">
                                <td>
                                    <xsl:value-of select="document-uri(.)"/>
                                </td>
                                <xsl:variable name="in-file" select="tokenize(document-uri(.), '/')[last()]" as="xs:string"/>
                                <!-- Contructed file names -->
                                <xsl:variable name="mets-file" select="ropen:concat-path($mets-collection, $in-file)" as="xs:anyURI"/>
                                <xsl:variable name="tei-enriched-file" select="ropen:concat-path($tei-enriched-collection, $in-file)" as="xs:anyURI"/>
                                <xsl:variable name="structure-file" select="ropen:concat-path($structure-collection, $in-file)" as="xs:anyURI"/>
                                <xsl:variable name="xhtml-content-file" select="ropen:concat-path($xhtml-collection, $in-file)" as="xs:anyURI"/>
                                <xsl:variable name="xhtml-header-file" select="ropen:concat-path($xhtml-header-collection, $in-file)" as="xs:anyURI"/>
                                <td>
                                    <xsl:value-of select="$in-file"/>
                                </td>
                                <xsl:if test="$tei-enriched-collection != ''">
                                    <td>
                                        <span>
                                            <!-- This needs to be an Template since result documents can't be used inside functions -->
                                            <xsl:variable name="success" as="xs:boolean">
                                                <xsl:call-template name="ropen:enrich-tei">
                                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                                    <xsl:with-param name="output" select="$tei-enriched-file"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="check-success">
                                                <xsl:with-param name="success" select="$success"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="$tei-enriched-file"/>
                                        </span>
                                        <xsl:value-of select="$tei-enriched-file"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$mets-collection != ''">
                                    <td>
                                        <span>
                                            <!-- This needs to be an Template since result documents can't be used inside functions -->
                                            <xsl:variable name="success" as="xs:boolean">
                                                <xsl:call-template name="ropen:create-mets">
                                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                                    <xsl:with-param name="output" select="$mets-file"/>
                                                    <xsl:with-param name="doc-name"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="check-success">
                                                <xsl:with-param name="success" select="$success"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="$mets-file"/>
                                        </span>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$structure-collection != ''">
                                    <td>
                                        <span>
                                            <!-- This needs to be an Template since result documents can't be used inside functions -->
                                            <xsl:variable name="success" as="xs:boolean">
                                                <xsl:call-template name="ropen:xhtml-structure">
                                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                                    <xsl:with-param name="output" select="$structure-file"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:message terminate="no">Warning the structure is created from TEI and dosn't contain IDs! Use structure-extractor.xsl instead.</xsl:message>
                                            <xsl:call-template name="check-success">
                                                <xsl:with-param name="success" select="$success"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="$structure-file"/>
                                        </span>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$xhtml-collection != ''">
                                    <td>
                                        <span>
                                            <!-- This needs to be an Template since result documents can't be used inside functions -->
                                            <xsl:variable name="success" as="xs:boolean">
                                                <xsl:call-template name="ropen:xhtml-content">
                                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                                    <xsl:with-param name="output" select="$xhtml-content-file"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="check-success">
                                                <xsl:with-param name="success" select="$success"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="$xhtml-content-file"/>
                                        </span>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$xhtml-header-collection != ''">
                                    <td>
                                        <span>
                                            <!-- This needs to be an Template since result documents can't be used inside functions -->
                                            <xsl:variable name="success" as="xs:boolean">
                                                <xsl:call-template name="ropen:xhtml-header">
                                                    <xsl:with-param name="input" select="document-uri(.)"/>
                                                    <xsl:with-param name="output" select="$xhtml-header-file"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="check-success">
                                                <xsl:with-param name="success" select="$success"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="$xhtml-header-file"/>
                                        </span>
                                    </td>
                                </xsl:if>
                            </xsl:for-each>
                        </tr>
                    </table>
                </xsl:if>
                <!-- Generate document listing -->
                <xsl:if test="$document-listing-file != ''">
                    <xsl:variable name="document-listing" as="element()">
                        <docs xmlns="">
                            <xsl:for-each select="collection(concat($collection, '/?select=*.xml'))">
                                <xsl:variable name="doc-id">
                                    <xsl:value-of select="ropen:uri-to-name(document-uri(root(.)))"/>
                                </xsl:variable>
                                <!--
                        <xsl:variable name="filename" select="document(.)"/>
                        -->
                                <doc>
                                    <id>
                                        <xsl:copy-of select="$doc-id"/>
                                    </id>
                                    <title>
                                        <xsl:value-of select="./TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]/text()"/>
                                    </title>
                                    <titleShort>
                                        <xsl:value-of select="./TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[@type = 'display']/text()"/>
                                    </titleShort>
                                    <!-- If METS file was created -->
                                    <xsl:if test="$mets-collection != ''">
                                        <xsl:variable name="doc-mets-file" select="ropen:create-path($prepend-prefix, $replace-prefix, concat($mets-collection, $doc-id, '.xml'))" as="xs:string"/>
                                        <!-- Wrap this in a file check if needed, see ropen:file-exists($file) -->
                                        <mets>
                                            <xsl:value-of select="$doc-mets-file"/>
                                        </mets>
                                        <xsl:variable name="mets" select="document($doc-mets-file)"/>
                                        <preview>
                                            <xsl:value-of select="data($mets//METS:fileGrp[@USE = 'MIN']//METS:file[1]/METS:FLocat/@xlink:href)"/>
                                        </preview>
                                    </xsl:if>
                                    <xsl:variable name="doc-tei-file" select="ropen:create-path($prepend-prefix, $replace-prefix, concat($collection, $doc-id, '.xml'))" as="xs:string"/>
                                    <!-- Wrap this in a file check if needed, see ropen:file-exists($file) -->
                                    <tei>
                                        <xsl:value-of select="$doc-tei-file"/>
                                    </tei>
                                    <!-- If a enriched file was created -->
                                    <xsl:if test="$tei-enriched-collection != ''">
                                        <xsl:variable name="doc-tei-enriched-file" select="ropen:create-path($prepend-prefix, $replace-prefix, concat($tei-enriched-collection, $doc-id, '.xml'))"
                                            as="xs:string"/>
                                        <!-- Wrap this in a file check if needed, see ropen:file-exists($file) -->
                                        <teiEnriched>
                                            <xsl:value-of select="$doc-tei-enriched-file"/>
                                        </teiEnriched>
                                    </xsl:if>
                                    <pageCount>
                                        <xsl:value-of select="count(.//TEI:pb)"/>
                                    </pageCount>
                                    <fulltext>
                                        <xsl:choose>
                                            <xsl:when test=".//TEI:body/*">
                                                <xsl:text>true</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>false</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </fulltext>
                                </doc>
                            </xsl:for-each>
                        </docs>
                    </xsl:variable>
                    <xsl:result-document href="{$document-listing-file}" exclude-result-prefixes="xlink xhtml" encoding="UTF-8">
                        <xsl:copy-of select="$document-listing"/>
                    </xsl:result-document>
                    <p>
                Document listing saved to <xsl:value-of select="$document-listing-file"/>.</p>
                </xsl:if>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="text()|comment()|processing-instruction()"/>

    <xsl:template name="ropen:create-mets" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:param name="doc-name" as="xs:string"/>
        <!-- This should overwite the parameters for the image locations -->
        <xsl:variable name="locationPrefix" select="$url-prefix"/>
        <xsl:variable name="identifier" select="ropen:uri-to-name($input)"/>
        <xsl:result-document href="{$output}" exclude-result-prefixes="xhtml" encoding="UTF-8">
            <xsl:apply-templates select="document($input)" mode="mets"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>

    <xsl:template name="ropen:enrich-tei" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:result-document href="{$output}" encoding="UTF-8">
            <xsl:apply-templates select="document($input)" mode="enrichment"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>

    <xsl:template name="ropen:xhtml-structure" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:result-document href="{$output}" encoding="UTF-8">
            <xsl:apply-templates select="document($input)" mode="xhtml-structure"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>

    <xsl:function name="ropen:create-path" as="xs:string">
        <xsl:param name="prepend" as="xs:string"/>
        <xsl:param name="replace" as="xs:string"/>
        <xsl:param name="path-parts" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="$replace = ''">
                <xsl:value-of select="concat($prepend, string-join($path-parts, '/'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($prepend, replace(string-join($path-parts, '/'), $replace, ''))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- TODO: Test this -->
    <xsl:template name="ropen:xhtml-content" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:result-document href="{$output}">
            <xsl:apply-templates select="document($input)"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>
    <xsl:template name="ropen:xhtml-header" as="xs:boolean">
        <xsl:param name="input" as="xs:anyURI"/>
        <xsl:param name="output" as="xs:anyURI"/>
        <xsl:result-document href="{$output}">
            <xsl:apply-templates select="document($input)//TEI:header"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:template>

    <xsl:template name="check-success" as="attribute()">
        <xsl:param name="success" as="xs:boolean"/>
        <xsl:attribute name="style">
            <xsl:choose>
                <xsl:when test="$success">
                    <xsl:text>color: green;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>color: red;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

</xsl:stylesheet>
