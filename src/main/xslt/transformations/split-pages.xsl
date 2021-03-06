<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:TEI="http://www.tei-c.org/ns/1.0"
    xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt"
    exclude-result-prefixes="xs xd a18 exist xlink xhtml ropen" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 14, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <!-- If a collection shoulb be processed, use this parameter otherwise the given document will be processed -->
    <xsl:param name="input-collection" select="''" as="xs:string"/>
    <!-- Output location, otherwise . -->
    <xsl:param name="output-collection" select="''" as="xs:string"/>
    <!-- Name of the document, used as file name prefix for pages -->
    <xsl:param name="document" select="''" as="xs:string"/>
    <!-- Use 'xhtml', 'tei' or 'kml' -->
    <xsl:param name="mode" select="'tei'" as="xs:string"/>
    <!-- copy TEI header into every page? -->
    <xsl:param name="copy-header" select="false()" as="xs:boolean"/>
    <xsl:param name="debug-output-collection" as="xs:string" select="''"/>

    <!-- Imports -->
    <xsl:include href="./gettyQuery.xsl"/>
    <xsl:include href="./TEI2XHTML.xsl"/>
    <xsl:include href="./lib/ropen.xsl"/>
    <!--
    <xsl:variable name="filterAnnotations" select="true()" as="xs:boolean"/>
    -->

    <xsl:template match="/" priority="10">
        <!-- Find out if we are processing a single Document or a collection -->
        <xsl:choose>
            <xsl:when test="$input-collection != ''">
                <xsl:message>Processing input <xsl:value-of select="$input-collection"/></xsl:message>
                <xsl:for-each select="collection(concat($input-collection, '/?select=*.xml'))">
                    <xsl:variable name="input-file" select="document-uri(.)"/>
                    <xsl:message>Processing file <xsl:value-of select="$input-file"/></xsl:message>
                    <!-- Using just ./* here makes Saxon forget about the uri of the document -->
                    <xsl:apply-templates select="doc($input-file)/TEI:TEI/*" mode="split"/>
                    <!--
                    <xsl:if test="$debug-output-collection and $mode = 'xhtml'">
                        <xsl:variable name="debug-output-file" select="concat($debug-output-collection, '/', ropen:document-name(.), '.xhtml')"/>
                        <xsl:message>Genetrating debug file <xsl:value-of select="$debug-output-file"/></xsl:message>
                        <xsl:result-document href="{$debug-output-file}">
                            <html xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                                xmlns:bibo="http://purl.org/ontology/bibo/1.3/" version="XHTML+RDFa 1.0" type="bibo:Manuscript">
                                <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                                <meta charset="UTF-8"/>
                                <title>
                                    <xsl:choose>
                                        <xsl:when test="//TEI:title[@display]">
                                            <xsl:value-of select="//TEI:title[@display]/text()"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="//TEI:title[1]/text()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </title>
                                <body>
                                    <xsl:apply-templates select="." mode="xhtml" exclude-result-prefixes="TEI xhtml"/>
                                </body>
                            </html>
                        </xsl:result-document>
                    </xsl:if>
                    -->
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="split"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="//TEI:text/TEI:body" priority="10" mode="split">
        <xsl:message>Document is: <xsl:value-of select="document-uri(root(.))"/></xsl:message>
        <xsl:variable name="suffix">
            <xsl:choose>
                <xsl:when test="$mode = 'tei'">
                    <xsl:value-of select="'.tei.xml'"/>
                </xsl:when>
                <xsl:when test="$mode = 'xhtml'">
                    <xsl:value-of select="'.xhtml'"/>
                </xsl:when>
                <xsl:when test="$mode = 'kml'">
                    <xsl:value-of select="'.kml'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="page-name" select="a18:page-name(.)" as="xs:string"/>
        <xsl:for-each select="//TEI:pb"> <!-- without last page -->
            <xsl:variable name="pos" select="position()" as="xs:integer"/>   
            
            <xsl:variable name="page" as="node()*">
                <xsl:choose>  
                    <xsl:when test="position() = 1 ">
                        <xsl:copy-of select="a18:chunk(./preceding::TEI:milestone[1], ., //TEI:body)"/>   
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="a18:chunk(./preceding::TEI:pb[1], ., //TEI:body)"/>   
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="file-name">
                <xsl:choose>
                    <xsl:when test="$output-collection != ''">
                        <xsl:value-of select="concat($output-collection, '/', $page-name, '-', $pos, $suffix)"/>
                    </xsl:when>
                    <xsl:when test="$mode = 'xhtml'">
                        <xsl:value-of select="concat('./', $page-name, '-', $pos, $suffix)"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>
             <xsl:call-template name="a18:generate-page">
                 <xsl:with-param name="file-name"><xsl:value-of select="$file-name" /></xsl:with-param>
                 <xsl:with-param name="page"><xsl:copy-of select="$page" /></xsl:with-param>
                 <xsl:with-param name="pos"><xsl:value-of select="$pos" /></xsl:with-param>
             </xsl:call-template>
        </xsl:for-each>
        
        <!-- lastpage -->
        <xsl:variable name="pos" as="xs:integer"><xsl:value-of select="count(//TEI:pb)+1" /></xsl:variable> 
        <xsl:variable name="page" as="node()*">
            <xsl:copy-of select="a18:chunk((//TEI:pb)[last()], (//TEI:milestone)[last()], //TEI:body)"/>  
        </xsl:variable>
        <xsl:variable name="file-name">
            <xsl:choose>
                <xsl:when test="$output-collection != ''">
                    <xsl:value-of select="concat($output-collection, '/', $page-name, '-', $pos, $suffix)"/>
                </xsl:when>
                <xsl:when test="$mode = 'xhtml'">
                    <xsl:value-of select="concat('./', $page-name, '-', $pos, $suffix)"/>
                </xsl:when>
                <xsl:when test="$mode = 'kml'">
                    <xsl:value-of select="concat('./', $page-name, '-', $pos, $suffix)"/>
                </xsl:when>
                   <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="a18:generate-page">
            <xsl:with-param name="file-name"><xsl:value-of select="$file-name" /></xsl:with-param>
            <xsl:with-param name="page"><xsl:copy-of select="$page" /></xsl:with-param>
            <xsl:with-param name="pos"><xsl:value-of select="$pos" /></xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>



<xsl:template name="a18:generate-page" >
    <xsl:param name="file-name" />
    <xsl:param name="page" />
    <xsl:param name="pos" />
    
    <xsl:message>Generating result file <xsl:value-of select="$file-name"/> mode: <xsl:value-of select="$mode"/></xsl:message>
    <xsl:variable name="tei-page">
        <TEI:TEI xmlns:TEI="http://www.tei-c.org/ns/1.0">
            <TEI:teiHeader>
                <xsl:if test="$copy-header">
                    <xsl:copy-of select="//TEI:teiHeader/*"/>
                </xsl:if>
            </TEI:teiHeader>
            <TEI:text>
                <TEI:body>
                    <xsl:copy-of select="a18:filter-pb($page)"/>
                    <xsl:if test="not(a18:filter-pb($page)//TEI:pb)">  
                        <TEI:pb />
                        <!-- <xsl:copy-of select="."/> -->
                    </xsl:if> 
                </TEI:body>
            </TEI:text>
        </TEI:TEI>
    </xsl:variable>
    <xsl:result-document href="{$file-name}">
        <xsl:choose>
            <xsl:when test="$mode = 'tei'">
                <xsl:copy-of select="$tei-page"/>
            </xsl:when>
            <xsl:when test="$mode = 'xhtml'">
                <html xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                    xmlns:bibo="http://purl.org/ontology/bibo/1.3/" version="XHTML+RDFa 1.0" type="bibo:Manuscript">
                    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                    <meta charset="UTF-8"/>
                    <title>Page <xsl:value-of select="$pos"/></title>
                    <body>
                        <xsl:apply-templates select="$tei-page" mode="fragment" exclude-result-prefixes="TEI xhtml"/>
                    </body>
                </html>
            </xsl:when>
            <xsl:when test="$mode = 'kml'">
                <!-- <xsl:message terminate="yes">Starting kml transformation (for single pages)</xsl:message> -->
                <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:kml="http://www.opengis.net/kml/2.2">
                    <Document>
                        <xsl:apply-templates select="$tei-page//TEI:placeName" mode='kml' />
                    </Document>
                </kml>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:result-document>
</xsl:template>


    <!-- Wrapper for XHTML templates-->
    <xsl:template match="/TEI:TEI/TEI:text/TEI:body" mode="xhtml">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="/TEI:TEI/TEI:teiHeader" mode="xhtml"/>

    <!-- Get rid of TEI:addName's -->
    <xsl:template match="TEI:addName" priority="10"/>

    <xsl:function name="a18:page-name">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <xsl:when test="$input-collection = '' and $document != ''">
                <xsl:value-of select="$document"/>
            </xsl:when>
            <xsl:when test="$input-collection != '' and ropen:document-name($node) != ''">
                <xsl:value-of select="ropen:document-name($node)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'page'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
