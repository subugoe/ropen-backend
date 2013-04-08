<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sub="http://sub.uni-goettingen.de/xslt/functions/1.0" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:a18="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/xslt" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="a18 sub xd"><xd:doc scope="stylesheet"><xd:desc><xd:p><xd:b>Created on:</xd:b> Aug 18, 2011</xd:p><xd:p><xd:b>Author:</xd:b> cmahnke</xd:p><xd:p/></xd:desc></xd:doc><xsl:output method="xml" indent="no" encoding="UTF-8"/><xsl:strip-space elements="TEI:persName TEI:note TEI:placeName"/>
    <!-- External parameters are parsed --><xsl:param name="filter-annotations-param" select="true()"/><xsl:param name="line-mode-param" select="false()"/><xsl:param name="resolve-links-param" select="true()"/><xsl:param name="fatal-param" select="false()"/><xsl:param name="nested-links-param" select="false()"/>
    <!-- Iternal Variables for parameters --><xsl:variable name="filterAnnotations" select="if ($filter-annotations-param castable as xs:boolean) then xs:boolean($filter-annotations-param) else true()" as="xs:boolean"/><xsl:variable name="lineMode" select="if ($line-mode-param castable as xs:boolean) then xs:boolean($line-mode-param) else false()" as="xs:boolean"/><xsl:variable name="resolve-links" select="if ($resolve-links-param castable as xs:boolean) then xs:boolean($resolve-links-param) else true()" as="xs:boolean"/><xsl:variable name="fatal" select="if ($fatal-param castable as xs:boolean) then xs:boolean($fatal-param) else false()" as="xs:boolean"/><xsl:variable name="nested-links" select="if ($nested-links-param castable as xs:boolean) then xs:boolean($nested-links-param) else false()" as="xs:boolean"/>
    <!-- 
    Always create a <a/> tag for the outer entity, even if there is no link in it. 
    --><xsl:variable name="always-link" select="true()" as="xs:boolean"/><xsl:variable name="prefixes"><a18:prefixes><a18:prefix name="getty" uri="http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=" pattern="GettyID:(\d{{7,8}})" start="GettyID"/><a18:prefix name="cerl" uri="http://thesaurus.cerl.org/cgi-bin/record.pl?rid=" pattern="CerlID:(cn[pi]\d{{8,9}})" start="CerlID"/><a18:prefix name="census" uri="http://census.bbaw.de/easydb/censusID=" pattern="CensusID:(\d{{9}})" start="CensusID"/><a18:prefix name="http" uri="http" pattern="http(s?://.*)" start="http"/><a18:prefix name="page" uri="#" pattern="(p.+)" start="p"/>
            <!-- This is needed for malformed URIs --><a18:prefix name="" uri="" pattern="(.+)" start=""/></a18:prefixes></xsl:variable><xsl:variable name="dnbURL" select="'http://d-nb.info/gnd/'" as="xs:string"/><xsl:variable name="class-prefix" select="'tei:'" as="xs:string"/><xsl:variable name="terminate" as="xs:string"><xsl:choose><xsl:when test="$fatal = true()"><xsl:value-of select="'yes'"/></xsl:when><xsl:otherwise><xsl:value-of select="'no'"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:template match="/">
        <!-- Use XSLT Modes to get rid of variables --><html xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:bibo="http://purl.org/ontology/bibo/1.3/" version="XHTML+RDFa 1.0" type="bibo:Manuscript"><xsl:variable name="pageMode" as="xs:boolean"><xsl:choose><xsl:when test="not(/TEI:TEI/TEI:teiHeader) and //TEI:text"><xsl:value-of select="true()"/></xsl:when><xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="fragmentMode" as="xs:boolean"><xsl:choose><xsl:when test="not(/TEI:TEI/TEI:teiHeader) and not(//TEI:text)"><xsl:value-of select="true()"/></xsl:when><xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:if test="$fragmentMode != true()"><head><xsl:if test="$pageMode != true()"><title type="dc:title"><xsl:value-of select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title/text()"/></title></xsl:if></head></xsl:if><body><xsl:if test="$lineMode = true()"><xsl:call-template name="lineSpan"><xsl:with-param name="nr" select="1"/></xsl:call-template></xsl:if><xsl:choose><xsl:when test="$pageMode = false() and $fragmentMode = false()"><xsl:apply-templates select="/TEI:TEI/TEI:text"/></xsl:when>
                    <!-- This will be used if in document fragment mode -->
                    <!-- This is needed if the document was cut by eXist --><xsl:when test="$pageMode = true()"><xsl:apply-templates select="//TEI:text"/></xsl:when>
                    <!-- This is needed if the document was cut by Lucene (result fragments) --><xsl:when test="$fragmentMode = true()"><xsl:apply-templates/></xsl:when></xsl:choose>
                <!-- TODO: use a mode for this stuff --><xsl:if test="$lineMode != true()"><xsl:if test="//TEI:note"><hr class="{'endOfDocument'}"/><xsl:call-template name="addNotes"/></xsl:if></xsl:if></body></html></xsl:template>
    <!-- Figures -->
    <!--
  TODO: Insert Link.
  --><xsl:template match="TEI:figure"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="de">Zeichnung/Skizze: siehe Digitalisat der Handschrift</span><span xml:lang="en">Figure/Sketch: see digitized manuscript</span><xsl:apply-templates/></div></xsl:template><xsl:template match="TEI:figDesc"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="de">Inhalt der Zeichnung/Skizze: </span><span xml:lang="en">Content of figure/sketch:</span><xsl:apply-templates/></div></xsl:template>

    <!-- Document blocks --><xsl:template match="TEI:div|TEI:p|TEI:del|TEI:q" mode="#all"><xsl:element name="{local-name(.)}"><xsl:attribute name="class" select="concat($class-prefix, local-name(.))"/><xsl:apply-templates/></xsl:element></xsl:template>

    <!-- breaks --><xsl:template match="TEI:lb|TEI:cb|TEI:handShift" name="br"><br class="{concat($class-prefix, local-name(.))}"/>
        <!-- TODO: This could be faster using a mode --><xsl:if test="$lineMode = true()"><xsl:call-template name="lineSpan"/></xsl:if></xsl:template><xsl:template match="TEI:lb|TEI:cb|TEI:handShift" mode="line"><xsl:call-template name="br"/><xsl:call-template name="lineSpan"/></xsl:template><xsl:template match="TEI:pb" mode="#all">
        <!--
        <xsl:call-template name="pageSpan"/>
        --><xsl:variable name="page-nr"><xsl:choose><xsl:when test="./@n"><xsl:value-of select="./@n"/></xsl:when><xsl:otherwise><xsl:value-of select="count(preceding::TEI:pb)"/></xsl:otherwise></xsl:choose></xsl:variable><a name="{concat('p', $page-nr)}"/><hr class="{concat($class-prefix, local-name(.))}"/>
        <!-- TODO: use a mode for this stuff --><xsl:if test="count(following-sibling::TEI:pb) &lt; 1 and $lineMode = true()"><xsl:call-template name="lineSpan"><xsl:with-param name="nr" select="1"/></xsl:call-template></xsl:if></xsl:template><xsl:template match="TEI:sic|TEI:corr" mode="#all"><span class="{concat($class-prefix, local-name(.))}"><xsl:apply-templates/></span></xsl:template>
    <!-- headings --><xsl:template match="TEI:head" mode="#all"><xsl:element name="{concat('h', count(ancestor::TEI:div))}"><xsl:attribute name="class" select="concat($class-prefix, local-name(.))"/><xsl:variable name="id"><xsl:value-of select="parent::TEI:div/@id"/></xsl:variable><xsl:choose><xsl:when test="$id != ''"><a name="{$id}" class="{concat(name(.), '-anchor')}"><xsl:apply-templates/></a></xsl:when><xsl:otherwise><xsl:apply-templates/></xsl:otherwise></xsl:choose></xsl:element><xsl:if test="count(ancestor::TEI:div) &gt; 9"><xsl:message terminate="yes">TEI2XHTML: Nesting to high, max is 9, <xsl:value-of select="count(ancestor::TEI:div)"/> given!</xsl:message></xsl:if></xsl:template><xsl:template match="TEI:emph"><em class="{concat($class-prefix, local-name(.))}"><xsl:apply-templates/></em></xsl:template><xsl:template match="TEI:add|TEI:expan|TEI:supplied"><ins><xsl:choose><xsl:when test="@resp"><xsl:call-template name="addClass"><xsl:with-param name="additional-classes" select="true()">
                            <!--
                            <xsl:call-template name="attribute-class"/>
                            --></xsl:with-param></xsl:call-template></xsl:when><xsl:otherwise><xsl:attribute name="class" select="concat($class-prefix, local-name(.))"/></xsl:otherwise></xsl:choose><xsl:apply-templates/></ins></xsl:template><xsl:template match="TEI:unclear|TEI:damage|TEI:gap|TEI:foreign|TEI:fw" mode="#all"><span class="{concat($class-prefix, local-name(.))}"><xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang"/></xsl:if><xsl:apply-templates/></span></xsl:template><xsl:template match="TEI:choice" mode="#all"><span class="{concat($class-prefix, local-name(.))}"><xsl:apply-templates select="./TEI:sic"/><xsl:text> [</xsl:text><xsl:apply-templates select="./TEI:corr"/><xsl:text>]</xsl:text></span></xsl:template><xsl:template match="TEI:hi" mode="#all"><span class="{concat($class-prefix, local-name(.), '-', translate(@rend, ' ', '-'))}"><xsl:apply-templates/></span></xsl:template>

    <!-- Column breaks inside the text --><xsl:template match="TEI:milestone" mode="#all"><xsl:choose><xsl:when test="@unit = 'column' and @type = 'start'"><xsl:variable name="columns" select="./following::*[not(./preceding::TEI:milestone[@unit='column'][@type='end'])]"/>

                <!--
                ./following::*[not(./preceding::TEI:milestone[@unit='column'][@type='end'])]
                --><xsl:for-each select="$columns//TEI:cb"><div class="column"><xsl:apply-templates/></div></xsl:for-each></xsl:when><xsl:when test="@unit = 'column' and @type = 'end'"/><xsl:otherwise><xsl:message terminate="yes">TEI2XHTML: Undeclared attribute for element
                    TEI:milestone detected: <xsl:value-of select="@unit"/></xsl:message></xsl:otherwise></xsl:choose></xsl:template>

    <!-- Entities (inkluding pseudo entities - everything that links) start here --><xsl:template match="TEI:term|TEI:bibl|TEI:placeName|TEI:persName|TEI:ref">
        <!-- The following pattern can be used to find multiple links "#[^"]*?#.*?" for one entity 
             The following XPath can be used to fin nested linking entities
        -->
        <!-- 
        TODO: Check if there are child, of one of the entities, if that's the case,
        create <span/>'s instead of <a/>'s.
        <span/>'s should use a xlink:to attrubute for the links
        
        --><xsl:variable name="parent-links" as="xs:boolean"><xsl:choose><xsl:when test="ancestor::TEI:term|ancestor::TEI:bibl|ancestor::TEI:placeName|ancestor::TEI:persName|ancestor::TEI:ref"><xsl:value-of select="true()"/></xsl:when><xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="ref-str" as="xs:string"><xsl:choose><xsl:when test="@ref"><xsl:value-of select="@ref"/></xsl:when><xsl:when test=". instance of element(TEI:bibl)"><xsl:value-of select="./TEI:ref/@target"/></xsl:when><xsl:when test=". instance of element(TEI:ref)"><xsl:value-of select="@target"/></xsl:when><xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise></xsl:choose></xsl:variable>

        <!-- select="if (sub:count-occurrences($ref-str, '#') > 1) then true() else false()"  --><xsl:variable name="nested" as="xs:boolean"><xsl:choose><xsl:when test="sub:count-occurrences($ref-str, '#') &gt; 1"><xsl:value-of select="true()"/></xsl:when><xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise></xsl:choose></xsl:variable>

        <!-- select="if ($nested) then a18:tokenize-ids($ref-str) else $ref-str"  --><xsl:variable name="targets" as="item()*"><xsl:choose><xsl:when test="$nested"><xsl:copy-of select="a18:tokenize-ids($ref-str)"/>
                    <!--
                    <xsl:copy-of select="tokenize($ref-str, '\s+')"/>
                      --></xsl:when>
                <!-- Change target to an empty sequece if link is invalid. --><xsl:when test="$ref-str = '#' or $ref-str = ''"/><xsl:otherwise><xsl:value-of select="($ref-str)"/></xsl:otherwise></xsl:choose></xsl:variable>

        <!-- select="if (not(empty($targets))) then 'a' else 'span'" --><xsl:variable name="element" as="xs:string"><xsl:choose><xsl:when test="not(empty($targets)) and not($parent-links) and not($nested-links)"><xsl:text>a</xsl:text></xsl:when><xsl:when test="not(empty($targets)) and $parent-links and $nested-links"><xsl:text>a</xsl:text></xsl:when><xsl:when test="$always-link and not($parent-links) and not($nested-links)"><xsl:text>a</xsl:text></xsl:when><xsl:otherwise><xsl:text>span</xsl:text></xsl:otherwise></xsl:choose></xsl:variable>
        <!-- Put the children in a variable --><xsl:variable name="content"><xsl:choose><xsl:when test="not(. instance of element(TEI:bibl))"><xsl:apply-templates select="./node()"/></xsl:when><xsl:otherwise><xsl:apply-templates select="./TEI:ref/node()"/></xsl:otherwise></xsl:choose></xsl:variable>
        <!-- Put common attributes in a variable --><xsl:variable name="attr" as="element(a18:attributes)"><a18:attributes class="{concat($class-prefix, local-name(.))}">
                <!--
                <xsl:if test="$element = 'a' and not (. instance of element(TEI:bibl))">
                --><xsl:if test="$element = 'a'"><xsl:attribute name="target" select="'_blank'"/></xsl:if><xsl:choose><xsl:when test=". instance of element(TEI:placeName)"><xsl:attribute name="type" select="'gn:name'"/></xsl:when><xsl:when test=". instance of element(TEI:persName)"><xsl:attribute name="type" select="'foaf:name'"/><xsl:if test="@key"><xsl:attribute name="about" select="concat($dnbURL, translate(@key, '#PND:', ''))"/></xsl:if></xsl:when><xsl:when test=". instance of element(TEI:bibl)"><xsl:attribute name="type" select="'bibo:Book'"/></xsl:when></xsl:choose></a18:attributes></xsl:variable><xsl:variable name="link-attribute"><xsl:choose><xsl:when test="empty($targets)"><xsl:value-of select="''"/></xsl:when><xsl:when test="not($nested-links) and $parent-links"><xsl:value-of select="'xlink:to'"/></xsl:when><xsl:otherwise><xsl:value-of select="'href'"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:element name="{$element}"><xsl:copy-of select="$attr/@*"/><xsl:if test="$link-attribute != ''">
                <!-- select="if ($resolve-links = true()) then a18:resolve-id($targets[1]) else $targets[1]" --><xsl:attribute name="{$link-attribute}"><xsl:choose><xsl:when test="$resolve-links = true()"><xsl:value-of select="a18:resolve-id($targets[1])"/></xsl:when><xsl:otherwise><xsl:value-of select="$targets[1]"/></xsl:otherwise></xsl:choose></xsl:attribute></xsl:if><xsl:choose><xsl:when test="$nested"><xsl:call-template name="nestedLinks"><xsl:with-param name="links" select="subsequence($targets, 2)"/><xsl:with-param name="content" select="$content"/><xsl:with-param name="attributes" select="$attr"/><xsl:with-param name="resolve-links" select="$resolve-links"/><xsl:with-param name="element-name" select="if ($nested-links) then 'a' else 'span'"/><xsl:with-param name="attribute-name" select="if ($nested-links) then 'href' else 'xlink:to'"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:copy-of select="$content"/></xsl:otherwise></xsl:choose></xsl:element>

        <!--
        <xsl:choose>
            <xsl:when test="$nested">
                <xsl:call-template name="nestedLinks">
                    <xsl:with-param name="links" select="$targets"/>
                    <xsl:with-param name="content" select="$content"/>
                    <xsl:with-param name="attributes" select="$attr"/>
                    <xsl:with-param name="resolve-links" select="$resolve-links"/>
                    <xsl:with-param name="element-name" select="$element"/>
                    <xsl:with-param name="attribute-name" select="$attribute"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$element}">
                    <xsl:copy-of select="$attr/@*"/>
                    <xsl:if test="$element = 'a'">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$resolve-links = true()">
                                    <xsl:value-of select="a18:resolve-id($targets[1])"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$targets[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="$content"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        --></xsl:template>
    <!-- Dates --><xsl:template match="TEI:date" mode="#all"><span class="{concat($class-prefix, local-name(.))}"><xsl:if test="@when"><xsl:attribute name="property" select="'dc:date'"/><xsl:attribute name="content" select="@date"/></xsl:if><xsl:apply-templates/></span></xsl:template>
    <!-- Notes --><xsl:template match="TEI:note"><xsl:choose><xsl:when test="@place = 'margin'"><span class="{concat($class-prefix, local-name(.))}"><xsl:apply-templates/></span></xsl:when><xsl:when test="@type = 'certainty'"><span style="display: none;"><xsl:call-template name="addClass"><xsl:with-param name="additional-classes" select="true()">
                            <!--
                            <xsl:call-template name="attribute-class"/>
                            --></xsl:with-param></xsl:call-template><xsl:apply-templates/></span></xsl:when>
            <!-- TODO: use a mode for this stuff --><xsl:when test="$lineMode != true()"><xsl:variable name="target"><xsl:choose><xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when><xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise></xsl:choose></xsl:variable><a class="{concat($class-prefix, local-name(.))}" href="{concat('#', $target)}" name="{concat('return_', $target)}"><xsl:text>[</xsl:text><xsl:number level="any"/><xsl:text>]</xsl:text></a></xsl:when><xsl:otherwise><div class="{concat($class-prefix, local-name(.))}"><xsl:apply-templates/></div></xsl:otherwise></xsl:choose></xsl:template>
    <!-- Catch undeclared TEI tags -->
    <!--
        TODO:
            * Merge this with template match="*"
       
        --><xsl:template match="TEI:*" mode="#all"><xsl:if test="not(ancestor-or-self::TEI:teiHeader)"><xsl:message terminate="yes">TEI2XHTML: Undeclared Element detected <xsl:value-of select="local-name(.)"/>: <xsl:value-of select="."/></xsl:message><xsl:element name="{name()}"><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:element></xsl:if></xsl:template>
    <!--
    <xsl:template match="*">
        <xsl:if test="not(ancestor-or-self::TEI:teiHeader)">
            <xsl:message terminate="yes">TEI2XHTML: Undeclared Element detected <xsl:value-of select="local-name(.)"/>: <xsl:value-of select="."/>
            </xsl:message>
            <xsl:element name="{name()}">
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    -->
    <!-- 
        Pass unknown elements, not in the TEI namesapace to the result.
        This is needed to transfom search results as a block
    --><xsl:template match="*"><xsl:variable name="passthru" select="true()" as="xs:boolean"/><xsl:if test="$passthru = true()"><xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy></xsl:if></xsl:template>

    <!-- TEI Structure --><xsl:template match="TEI:text|TEI:body" mode="#all"><xsl:apply-templates/></xsl:template>

    <!-- Stuff to ignore --><xsl:template match="TEI:ab" mode="#all"><xsl:apply-templates select="./*"/></xsl:template>

    <!-- 
    TODO: Check if this works
    --><xsl:template match="TEI:addName" mode="#all"><xsl:choose><xsl:when test="$filterAnnotations = true() and @type = 'display'"><span class="{concat($class-prefix, local-name(.))}" style="display: none;"><xsl:apply-templates/></span></xsl:when><xsl:when test="not($filterAnnotations)"><xsl:apply-templates/></xsl:when></xsl:choose></xsl:template>
    <!-- 
    This is needed by the highlighting of eXist
    --><xsl:template match="exist:match" mode="#all"><span class="{name(.)}"><xsl:apply-templates/></span></xsl:template>

    <!-- Try to normilize space 
         Check if whitespace only (\s*) and contains break, replace by one space
         otherwise use normal normalize function
    -->

    <!-- ./following::*[1] instance of element(TEI:lb) --><xsl:template match="TEI:p//text()" priority="1"><xsl:value-of select="a18:normalize-space(.)"/></xsl:template>

    <!--
    <xsl:template match="TEI:head//text()" priority="1">
        <xsl:value-of select="a18:normalize-space(.)"/>
    </xsl:template>
-->
    
    
    <!-- CSS Attributes --><xsl:template name="addClass"><xsl:param name="hide" select="false()" as="xs:boolean"/><xsl:param name="additional-classes" select="false()" as="xs:boolean"/><xsl:attribute name="class"><xsl:value-of select="concat($class-prefix, local-name(.))"/><xsl:if test="$additional-classes = true()"><xsl:text> </xsl:text><xsl:for-each select="@*"><xsl:value-of select="concat(name(.), '-', data(.))"/><xsl:if test="position() != last()"><xsl:value-of select="' '"/></xsl:if></xsl:for-each>
                <!--
                <xsl:value-of select="concat(' ', $additional-classes)"/>
                --></xsl:if></xsl:attribute><xsl:if test="$hide = true()"><xsl:attribute name="style" select="'display: none;'"/></xsl:if></xsl:template>
    <!--
    <xsl:template name="attribute-class">
        <xsl:for-each select="@*">
            <xsl:value-of select="concat(name(.), '-', data(.))"/>
            <xsl:if test="position() != last()">
                <xsl:value-of select="' '"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
-->
    <!-- This add the notes at the bottom --><xsl:template name="addNotes"><xsl:for-each select="//TEI:note[not(@place = 'margin')]"><div class="note-link"><xsl:variable name="target"><xsl:choose><xsl:when test="@id"><xsl:value-of select="./@id"/></xsl:when><xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise></xsl:choose></xsl:variable><a name="{$target}" href="{concat('#return_', $target)}" class="note-link-number"><xsl:text>[</xsl:text><xsl:number level="any"/><xsl:text>]</xsl:text></a><br/><xsl:apply-templates select="./*"/></div></xsl:for-each></xsl:template>
    <!-- needed for line and page numbering --><xsl:template name="lineSpan"><xsl:param name="nr"/><span><xsl:attribute name="class"><xsl:text>line</xsl:text><xsl:choose><xsl:when test="$nr != ''"><xsl:value-of select="$nr"/></xsl:when><xsl:otherwise><xsl:choose><xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when><xsl:otherwise><xsl:value-of select="count(preceding::TEI:pb[1]/following::TEI:lb) - count(following::TEI:lb) + 1"/></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:attribute></span></xsl:template><xsl:template name="pageSpan"><xsl:param name="nr"/><span><xsl:attribute name="class"><xsl:text>page</xsl:text><xsl:choose><xsl:when test="$nr != ''"><xsl:value-of select="$nr"/></xsl:when><xsl:otherwise><xsl:choose><xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when><xsl:otherwise><xsl:value-of select="count(preceding::TEI:pb)"/></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:attribute></span></xsl:template>
    <!-- Utility templates --><xsl:template name="nestedLinks">
        <!-- Links are supplied as tokens --><xsl:param name="links" as="item()*"/><xsl:param name="pos" select="1" as="xs:integer"/><xsl:param name="attributes" as="element(a18:attributes)"/><xsl:param name="content"/><xsl:param name="resolve-links" select="true()" as="xs:boolean"/><xsl:param name="element-name" select="'a'" as="xs:string"/><xsl:param name="attribute-name" select="'href'" as="xs:string"/><xsl:choose><xsl:when test="count($links) &gt;= $pos"><xsl:element name="{$element-name}"><xsl:copy-of select="$attributes/@*"/><xsl:attribute name="{$attribute-name}"><xsl:choose><xsl:when test="$resolve-links = true()"><xsl:value-of select="a18:resolve-id($links[$pos])"/></xsl:when><xsl:otherwise><xsl:value-of select="$links[$pos]"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:call-template name="nestedLinks"><xsl:with-param name="links" select="$links"/><xsl:with-param name="pos" select="$pos + 1"/><xsl:with-param name="attributes" select="$attributes"/><xsl:with-param name="content" select="$content"/><xsl:with-param name="resolve-links" select="$resolve-links"/><xsl:with-param name="element-name" select="$element-name"/><xsl:with-param name="attribute-name" select="$attribute-name"/></xsl:call-template></xsl:element></xsl:when><xsl:otherwise><xsl:copy-of select="$content"/></xsl:otherwise></xsl:choose></xsl:template>

    <!-- Templates for transformations of the header --><xsl:template match="TEI:teiHeader"><xsl:if test="(/TEI:teiHeader) and not(//TEI:text)"><div class="{concat($class-prefix, local-name(.))}"><h3><span xml:lang="de" class="tei:hi-bold">Allgemeine Informationen</span><span xml:lang="en" class="tei:hi-bold">General Information</span>:</h3><xsl:apply-templates mode="header" select="//TEI:titleStmt//TEI:title"/><xsl:apply-templates mode="header" select="//TEI:repository"/><xsl:apply-templates mode="header" select="//TEI:idno"/><xsl:apply-templates mode="header" select="//TEI:titleStmt//TEI:author"/><xsl:apply-templates mode="header" select="//TEI:origDate"/><xsl:apply-templates mode="header" select="//TEI:objectDesc"/><xsl:apply-templates mode="header" select="//TEI:titleStmt"/><xsl:apply-templates mode="header" select="//TEI:msIdentifier"/><xsl:apply-templates mode="header" select="//TEI:principal"/><h3><span xml:lang="de" class="tei:hi-bold">Wissenschaftliche Informationen</span><span xml:lang="en" class="tei:hi-bold">Scientific Informationen</span></h3><xsl:apply-templates mode="header" select="//TEI:editionStmt|//TEI:encodingDesc"/></div></xsl:if></xsl:template><xsl:template match="TEI:repository" mode="header"><xsl:variable name="name" select="normalize-space(string-join(./text(), ''))"/>
        <!--
        <xsl:variable name="name">
            <xsl:apply-templates/>
        </xsl:variable>
        --><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Library</span><span xml:lang="de" class="tei:hi-bold">Bibliothek</span>: <xsl:value-of select="$name"/></div></xsl:template><xsl:template match="TEI:title[not(@type)]" mode="header"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Title</span><span xml:lang="de" class="tei:hi-bold">Titel</span>: <xsl:value-of select="."/></div></xsl:template><xsl:template match="TEI:author" mode="header"><xsl:variable name="name" select="normalize-space(string-join(./text(), ''))"/>
        <!--
        <xsl:variable name="name">
            <xsl:apply-templates/>
        </xsl:variable>
        --><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Author / Copyist / Owner</span><span xml:lang="de" class="tei:hi-bold">Autor / Kopist / Besitzer</span>: <xsl:value-of select="$name"/></div></xsl:template><xsl:template match="TEI:objectDesc" mode="header"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Extent</span><span xml:lang="de" class="tei:hi-bold">Umfang</span>: <xsl:value-of select="."/></div></xsl:template><xsl:template match="TEI:origDate" mode="header"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Date</span><span xml:lang="de" class="tei:hi-bold">Datum</span>: <xsl:value-of select="."/></div></xsl:template><xsl:template match="TEI:principal" mode="header"><xsl:variable name="name" select="normalize-space(string-join(./text(), ''))"/>
        <!--
        <xsl:variable name="name">
            <xsl:apply-templates/>
        </xsl:variable>
        --><div class="{concat($class-prefix, local-name(.))}" style="display: none;"><span xml:lang="en" class="tei:hi-bold">Contact Person</span><span xml:lang="de" class="tei:hi-bold">Ansprechpartner</span>: <xsl:value-of select="$name"/></div></xsl:template><xsl:template match="TEI:idno" mode="header"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Shelf mark</span><span xml:lang="de" class="tei:hi-bold">Signatur</span>: <xsl:value-of select="."/><xsl:if test="../TEI:altIdentifier"><xsl:for-each select="../TEI:altIdentifier/idno"><xsl:text>, </xsl:text><xsl:value-of select="."/></xsl:for-each></xsl:if></div></xsl:template><xsl:template match="TEI:editorialDecl|TEI:edition|TEI:samplingDecl" mode="header"><div class="{concat($class-prefix, local-name(.))}"><xsl:value-of select="."/></div></xsl:template><xsl:template match="//TEI:titleStmt" mode="header" name="editors"><div class="{concat($class-prefix, local-name(.))}"><span xml:lang="en" class="tei:hi-bold">Editor(s)</span><span xml:lang="de" class="tei:hi-bold">Bearbeiter</span>: <xsl:for-each select=".//TEI:respStmt"><xsl:value-of select="./TEI:name"/><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each></div></xsl:template><xsl:template match="//TEI:msIdentifier" mode="header" name="location"><div class="{concat($class-prefix, local-name(.))}" style="display: none;"><span xml:lang="en" class="tei:hi-bold">Location</span><span xml:lang="de" class="tei:hi-bold">Standort</span>: <xsl:value-of select=".//TEI:settlement"/><xsl:text>, </xsl:text><xsl:value-of select=".//TEI:country"/></div></xsl:template><xsl:template match="TEI:editionStmt|TEI:encodingDesc" mode="header"><div class="{concat($class-prefix, local-name(.))}"><xsl:apply-templates/></div></xsl:template>
    <!--
    <xsl:template name="hideElement">
        <xsl:attribute name="style" select="'display: none;'"/>
    </xsl:template>
    -->
    <!--
    <xsl:template name="highlight-match">
        
    </xsl:template>
    -->

    <!-- Library functions --><xsl:function name="sub:count-occurrences" as="xs:integer"><xsl:param name="str" as="xs:string"/><xsl:param name="search" as="xs:string"/><xsl:value-of select="count(tokenize($str, $search)) - 1"/></xsl:function><xsl:function name="a18:tokenize-ids" as="item()*"><xsl:param name="str"/><xsl:for-each select="tokenize($str, '\s+')"><xsl:value-of select="."/></xsl:for-each></xsl:function><xsl:function name="a18:resolve-id" as="xs:string">
        <!-- See XQuery implementation in modules/archaeo18lib.xq --><xsl:param name="id" as="xs:string"/>
        <!-- Clean up leading # --><xsl:variable name="identifier" as="xs:string" select="replace($id, '^#(.*)$', '$1')"/><xsl:variable name="name" as="xs:string"><xsl:choose>
                <!-- URIs with schema prefix --><xsl:when test="contains($identifier, ':')"><xsl:value-of select="$prefixes//a18:prefix[@start = substring-before($identifier, ':')]/@name"/></xsl:when>
                <!-- local anchors --><xsl:when test="matches($id, '#[\w-]')"><xsl:value-of select="$prefixes//a18:prefix[@start = replace($identifier, '([A-Za-z]+).*', '$1')]/@name"/></xsl:when><xsl:otherwise>
                    <!-- This stylesheet will fail here, since a empty result for this variable will fail later on when it's given to the function. --><xsl:message terminate="{$terminate}">Can't extract prefix for id <xsl:value-of select="$id"/></xsl:message><xsl:value-of select="$prefixes//a18:prefix[@start = '']/@name"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:value-of select="concat($prefixes//a18:prefix[@name = $name]/@uri, replace($identifier, $prefixes//a18:prefix[@name = $name]/@pattern, '$1'))"/></xsl:function><xsl:function name="a18:normalize-space"><xsl:param name="str" as="xs:string"/><xsl:choose>
            <!-- TODO: no space if the next element is a lb - and contains($str, '
') --><xsl:when test="matches($str, '^\s*[\r\n]\s+$')"><xsl:value-of select="' '"/></xsl:when><xsl:otherwise><xsl:value-of select="$str"/>
                <!--
                <xsl:value-of select="normalize-space($str)"></xsl:value-of>
           --></xsl:otherwise></xsl:choose></xsl:function></xsl:stylesheet>