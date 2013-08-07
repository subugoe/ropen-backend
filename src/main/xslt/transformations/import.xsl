<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd ropen" version="2.0">
    <!-- Imports -->
    <xsl:import href="./metadata-enrichment.xsl"/>
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
                <td>Input</td>
                <td>Filename</td>
                <td>Enriched</td>
                <td>METS</td>
            </thead>

            <tr>
                <xsl:for-each select="collection(concat($collection, '/?select=*.xml'))">
                    <td>
                        <xsl:value-of select="."/>
                    </td>
                    <xsl:variable name="in-file">
                        <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                    </xsl:variable>

                    <!-- Contructed file names -->
                    <xsl:variable name="mets-file" select="ropen:concat-path($mets-collection, $in-file)"/>
                    <xsl:variable name="tei-enriched-file" select="ropen:concat-path($tei-enriched-collection, $in-file)"/>
                    <td>
                        <xsl:value-of select="$in-file"/>
                    </td>
                    <td>
                        <span>
                            <!--
                            <xsl:choose>
                                <xsl:when test="ropen:create-mets(., $mets-file)">
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
                            -->
                            <xsl:value-of select="$mets-file"/>
                        </span>
                    </td>
                    <td>
                        <span>
                            <xsl:choose>
                                <xsl:when test="ropen:enrich-tei(., $tei-enriched-file)">
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

    <xsl:function name="ropen:create-mets" as="xs:boolean">
        <xsl:param name="input"/>
        <xsl:param name="output"/>
        <xsl:result-document href="$output">
            <xsl:apply-templates select="document($input)"/>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:function>

    <xsl:function name="ropen:enrich-tei" as="xs:boolean">
        <xsl:param name="input"/>
        <xsl:param name="output"/>
        <xsl:variable name="result-tree">
            <xsl:apply-templates select="document($input)" mode="enrichment"/>
        </xsl:variable>
        <xsl:result-document href="$output">
            <xsl:copy-of select="$result-tree"></xsl:copy-of>
        </xsl:result-document>
        <xsl:value-of select="true()"/>
    </xsl:function>

    <xsl:function name="ropen:concat-path" as="xs:string">
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

    <!-- 
    declare function ingest:enrichTEI ($content as node()) as node() {
    ingest:transform($content, $archeao18conf:stylesheetImportEnrichStylesheet)
};

(:~
: Creates a METS file as node list
: @param a node containing the TEI
: @return a node containing the METS result
:)
declare function ingest:createMets ($content as node(), $identifier as xs:string) as node() {
    let $params := 
        <parameters>
            <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
            <param name="identifier" value="{$identifier}"/>
        </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetImportMetsStylesheet))
    return transform:transform($content, $transform, $params)
};

(:~
: Enriches the TEI with metadata like spelling variants
: @param a node containing the TEI
: @return a node containing the result
:)

declare function ingest:enrichTEIMetadata ($content as node()) as node() {
    (:
    let $params := 
        <parameters>
        </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetImportEnrichMetadataStylesheet))
    return transform:transform($content, $transform, $params)
    :)
    ingest:transform($content, $archeao18conf:stylesheetImportEnrichMetadataStylesheet)
};

(:~
: Enriches the TEI using the give stylesheet (internal function)
: @param a node containing the TEI
: @param a node containing the transformation
: @return a node containing the result
:)

declare function ingest:transform ($content as node(), $stylesheet as xs:string) as node() {
     let $params := 
        <parameters>
            <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
        </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, $stylesheet))
    return transform:transform($content, $transform, $params)
};

declare function ingest:importMETS($file as xs:string, $identifier as xs:string, $metsCollection as xs:string) as xs:boolean {
    let $metsDoc := ingest:createMets(doc($file), $identifier)
    let $metsStore := xmldb:store($metsCollection , concat($identifier, $archeao18conf:metsSuffix), $metsDoc)
    return true()    
};

(:TODO: Check if this throws an exception :)
declare function ingest:downloadMETS($url as xs:string, $identifier as xs:string, $metsCollection as xs:string) as xs:boolean {
    let $metsURL := if ($url castable as xs:anyURI)
                    then xs:anyURI($url)
                    else false()
    let $metsDoc := httpclient:get($metsURL, false(), ())//METS:mets
    let $metsStore := xmldb:store($metsCollection , concat($identifier, $archeao18conf:metsSuffix), $metsDoc)
    return true()
};

declare function ingest:importTEI($file as xs:string, $identifier as xs:string, $enrichedTeiCollection as xs:string) as xs:boolean  {
    let $enrichedDoc := ingest:enrichTEIMetadata(ingest:enrichTEI(doc($file)))
    let $teiStore := xmldb:store($enrichedTeiCollection , concat($identifier, $archeao18conf:teiEnrichedSuffix), $enrichedDoc)
    return true()
};
    
    -->
</xsl:stylesheet>
