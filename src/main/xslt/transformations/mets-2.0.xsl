<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:METS="http://www.loc.gov/METS/" xmlns:MODS="http://www.loc.gov/mods/v3" xmlns:DC="http://purl.org/dc/elements/1.1/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:DV="http://dfg-viewer.de/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Apr 17, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- 
    TODO:
    - Check if it works
    - Add a fallback to saxon:node-set() for older Saxon versions
    -->
    <xsl:output encoding="UTF-8" exclude-result-prefixes="#all" indent="yes"/>
    <xsl:param name="identifier" select="string('REPLACEME')"/>
    <xsl:param name="locationPrefix">http://134.76.21.92:8080/images/</xsl:param>
    <xsl:param name="locationSuffix">.jpeg</xsl:param>
    <xsl:variable name="physPrefix">phys</xsl:variable>
    <xsl:variable name="locPrefix">loc</xsl:variable>
    <xsl:variable name="filePrefix">file</xsl:variable>
    <xsl:variable name="useOrWidth">width</xsl:variable>
    <xsl:variable name="fileGroups">
        <group width="800" locationPrefix="" locationSuffix="">DEFAULT</group>
        <group width="500" locationPrefix="" locationSuffix="">MIN</group>
        <group width="120" locationPrefix="" locationSuffix="">THUMB</group>
        <group width="1200" locationPrefix="" locationSuffix="">MAX</group>
        <group width="0" locationPrefix="file:///data/images/" locationSuffix=".jpg">PRESENTATION</group>
    </xsl:variable>
    <xsl:template match="/" mode="#default mets">
        <METS:mets>
            <xsl:if test="$identifier = 'REPLACEME'">
                <xsl:comment>Replace the string 'REPLACEME' with the real dentifier using sed, if no
                    param was given</xsl:comment>
            </xsl:if>
            <xsl:call-template name="metsHeader"/>
            <!-- the file section -->
            <METS:fileSec>
                <xsl:variable name="nodes" select="//TEI:pb"/>
                <xsl:for-each select="$fileGroups/group">
                    <xsl:call-template name="pbFileSect">
                        <xsl:with-param name="use">
                            <xsl:value-of select="text()"/>
                        </xsl:with-param>
                        <xsl:with-param name="nodes" select="$nodes"/>
                        <xsl:with-param name="prefix" select="@locationPrefix"/>
                        <xsl:with-param name="suffix" select="@locationSuffix"/>
                        <xsl:with-param name="width" select="@width"/>
                    </xsl:call-template>
                </xsl:for-each>
            </METS:fileSec>
            <!-- The logical struct map -->
            <METS:structMap TYPE="LOGICAL">
                <METS:div TYPE="Monograph" DMDID="dmdSec_00000001" ADMID="amdSec_00000001">
                    <xsl:attribute name="ID">
                        <xsl:value-of select="$locPrefix"/>
                        <xsl:text>_</xsl:text>
                        <xsl:number format="00000001" value="1"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="/TEI:TEI/TEI:text/TEI:body" mode="mets"/>
                </METS:div>
            </METS:structMap>
            <!-- The physical struct map -->
            <METS:structMap TYPE="PHYSICAL">
                <METS:div TYPE="physSequence">
                    <xsl:attribute name="ID">
                        <xsl:value-of select="$physPrefix"/>
                        <xsl:text>_</xsl:text>
                        <xsl:number format="00000001" value="0"/>
                    </xsl:attribute>
                    <xsl:call-template name="pbPhysMap"/>
                </METS:div>
            </METS:structMap>
            <METS:structLink>
                <!-- Every page belongs to the logical structure of the whole document -->

                <!--
                <xsl:for-each select="//TEI:pb">
                    <METS:smLink>
                        <xsl:attribute name="xlink:from">
                            <xsl:value-of select="$locPrefix"/>
                            <xsl:text>_</xsl:text>
                            <xsl:number format="00000001" value="1"/>
                        </xsl:attribute>
                        <xsl:attribute name="xlink:to">
                            <xsl:value-of select="$physPrefix"/>
                            <xsl:text>_</xsl:text>
                            <xsl:number format="00000001" value="count(preceding::TEI:pb)"/>
                        </xsl:attribute>
                    </METS:smLink>
                </xsl:for-each>
                -->
                <METS:smLink>
                    <xsl:attribute name="xlink:from">
                        <xsl:value-of select="$locPrefix"/>
                        <xsl:text>_</xsl:text>
                        <xsl:number format="00000001" value="1"/>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:to">
                        <xsl:value-of select="$physPrefix"/>
                        <xsl:text>_</xsl:text>
                        <xsl:number format="00000001" value="0"/>
                    </xsl:attribute>
                </METS:smLink>
                <xsl:for-each select="//TEI:head">
                    <xsl:variable name="childPbs" select="ancestor::TEI:div[1]/descendant::TEI:pb"/>
                    <xsl:variable name="from">
                        <xsl:value-of select="$locPrefix"/>
                        <xsl:text>_</xsl:text>
                        <xsl:number format="00000001" value="count(preceding::TEI:head) + 5"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="count($childPbs) = 0">
                            <METS:smLink>
                                <xsl:attribute name="xlink:from">
                                    <xsl:value-of select="$from"/>
                                </xsl:attribute>
                                <xsl:attribute name="xlink:to">
                                    <xsl:value-of select="$physPrefix"/>
                                    <xsl:text>_</xsl:text>
                                    <xsl:number format="00000001" value="count(preceding::TEI:pb) + 1"/>
                                </xsl:attribute>
                            </METS:smLink>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$childPbs">
                                <METS:smLink>
                                    <xsl:attribute name="xlink:from">
                                        <xsl:value-of select="$from"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="xlink:to">
                                        <xsl:value-of select="$physPrefix"/>
                                        <xsl:text>_</xsl:text>
                                        <xsl:number format="00000001" value="count(preceding::TEI:pb) +1"/>
                                    </xsl:attribute>
                                </METS:smLink>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </METS:structLink>
        </METS:mets>
    </xsl:template>

    <!-- Creates the physical struct map -->
    <xsl:template name="pbPhysMap">
        <xsl:for-each select="//TEI:pb">
            <METS:div TYPE="page">
                <xsl:variable name="pageNr">
                    <xsl:number level="any" count="//TEI:pb"/>
                </xsl:variable>
                <xsl:variable name="pageId">
                    <xsl:number format="00000001" level="any" count="//TEI:pb"/>
                </xsl:variable>
                <xsl:attribute name="ORDER">
                    <xsl:value-of select="$pageNr"/>
                </xsl:attribute>
                <xsl:attribute name="ID">
                    <xsl:value-of select="$physPrefix"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="$pageId"/>
                </xsl:attribute>
                <xsl:for-each select="$fileGroups/group">
                    <METS:fptr>
                        <xsl:attribute name="FILEID">
                            <xsl:value-of select="$filePrefix"/>
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="$pageId"/>
                        </xsl:attribute>
                    </METS:fptr>
                </xsl:for-each>
            </METS:div>
        </xsl:for-each>
    </xsl:template>

    <!-- Creates a file group -->
    <xsl:template name="pbFileSect">
        <xsl:param name="nodes"/>
        <xsl:param name="id" select="$identifier"/>
        <xsl:param name="use"/>
        <xsl:param name="prefix" select="$locationPrefix"/>
        <xsl:param name="suffix" select="$locationSuffix"/>
        <xsl:param name="width"/>
        <METS:fileGrp>
            <xsl:attribute name="USE">
                <xsl:value-of select="$use"/>
            </xsl:attribute>
            <xsl:for-each select="$nodes">
                <METS:file MIMETYPE="image/jpeg">
                    <xsl:attribute name="ID">
                        <xsl:value-of select="$filePrefix"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="$use"/>
                        <xsl:text>_</xsl:text>
                        <xsl:number format="00000001" level="any" count="//TEI:pb"/>
                    </xsl:attribute>
                    <METS:FLocat LOCTYPE="URL">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="$prefix = ''">
                                    <xsl:value-of select="$locationPrefix"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$prefix"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$id = ''">
                                <xsl:message terminate="yes">No identifier given!</xsl:message>
                            </xsl:if>
                            <xsl:value-of select="$id"/>
                            <xsl:choose>
                                <xsl:when test="$useOrWidth = 'use'">
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$use"/>
                                    <xsl:text>/</xsl:text>
                                </xsl:when>
                                <xsl:when test="$useOrWidth = 'width'">
                                    <xsl:if test="$width = ''">
                                        <xsl:message terminate="yes">No width given!</xsl:message>
                                    </xsl:if>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$width"/>
                                    <xsl:text>/</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message terminate="yes">Wrong URL type, valid is 'use' and
                                        'width'</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:number format="00000001" level="any" count="//TEI:pb"/>
                            <xsl:choose>
                                <xsl:when test="$suffix = ''">
                                    <xsl:value-of select="$locationSuffix"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$suffix"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </METS:FLocat>
                </METS:file>
            </xsl:for-each>
        </METS:fileGrp>
    </xsl:template>
    <xsl:template match="TEI:div" mode="#default mets">
        <xsl:choose>
            <!-- Get rid of empty div tags -->
            <xsl:when test="TEI:head">
                <METS:div>
                    <xsl:apply-templates select="TEI:div|TEI:head" mode="mets"/>
                </METS:div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="TEI:div|TEI:head" mode="mets"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="TEI:head" mode="#default mets">
        <xsl:attribute name="ID">
            <xsl:value-of select="$locPrefix"/>
            <xsl:text>_</xsl:text>
            <xsl:number format="00000001" value="count(preceding::TEI:head) + 5"/>
        </xsl:attribute>
        <xsl:attribute name="TYPE">
            <xsl:text>Chapter</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="LABEL">
            <!-- Use this to remove line seperators -->
            <!--
                    <xsl:value-of select="replace(normalize-space(.), '- ', '')"/>
                -->
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="text()" mode="#default mets"/>
    <xsl:template name="metsHeader">
        <METS:dmdSec ID="dmdSec_00000001">
            <METS:mdWrap MDTYPE="MODS">
                <METS:xmlData>
                    <MODS:mods>
                        <MODS:titleInfo>
                            <MODS:title>
                                <xsl:value-of select="TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]"/>
                            </MODS:title>
                        </MODS:titleInfo>
                    </MODS:mods>
                </METS:xmlData>
            </METS:mdWrap>
        </METS:dmdSec>
        <METS:amdSec ID="amdSec_00000001">
            <METS:rightsMD ID="rights_00000001">
                <METS:mdWrap MDTYPE="OTHER" OTHERMDTYPE="DVRIGHTS" MIMETYPE="text/xml">
                    <METS:xmlData>
                        <DV:rights>
                            <DV:owner/>
                            <DV:ownerLogo/>
                            <DV:ownerSiteURL/>
                        </DV:rights>
                    </METS:xmlData>
                </METS:mdWrap>
            </METS:rightsMD>
            <METS:digiprovMD ID="digiprovMD_00000001">
                <METS:mdWrap MIMETYPE="text/xml" MDTYPE="OTHER" OTHERMDTYPE="DVLINKS">
                    <METS:xmlData>
                        <DV:links>
                            <DV:reference/>
                            <DV:presentation/>
                        </DV:links>
                    </METS:xmlData>
                </METS:mdWrap>
            </METS:digiprovMD>
        </METS:amdSec>
    </xsl:template>
</xsl:stylesheet>