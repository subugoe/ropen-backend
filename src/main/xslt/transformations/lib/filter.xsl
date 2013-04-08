<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0"><xd:doc scope="stylesheet"><xd:desc><xd:p><xd:b>Created on:</xd:b> Jun 20, 2012</xd:p><xd:p><xd:b>Author:</xd:b> cmahnke</xd:p><xd:p/></xd:desc></xd:doc><xsl:strip-space elements="TEI:persName TEI:placeName"/><xsl:template match="/"><xsl:apply-templates mode="filter"/></xsl:template><xsl:template match="@*|node()" mode="filter"><xsl:copy><xsl:apply-templates select="@*|node()" mode="filter"/></xsl:copy></xsl:template><xsl:template match="comment()" mode="filter"/><xsl:template match="TEI:addName" mode="filter"/><xsl:template match="TEI:persName|TEI:placeName" mode="filter"><xsl:choose><xsl:when test=".//exist:match"><xsl:element name="exist:match"><xsl:copy><xsl:for-each select="@*"><xsl:attribute name="{name(.)}" select="data(.)"/></xsl:for-each><xsl:apply-templates mode="filter"/></xsl:copy></xsl:element></xsl:when><xsl:otherwise><xsl:apply-templates mode="filter"/></xsl:otherwise></xsl:choose></xsl:template><xsl:template name="filter"><xsl:param name="nodes"/><xsl:apply-templates select="$nodes" mode="filter"/></xsl:template>

    <!--
declare function archaeo18lib:shorten ($content as element(), $focus as xs:string, $length as xs:integer) as element()* {
    let $focusNode := $content//*[local-name(.) = $focus][1]
    let $width := $length - string-length($focusNode/text())
    return if ($width < 0) then $focusNode
           else archaeo18lib:shorten-helper($focusNode, $width)
};

declare function archaeo18lib:shorten-helper ($context as element(), $width as xs:integer) as element()* {
    let $precedingSiblings := $context/preceding-sibling::* 
    let $followingSiblings := $context/following-sibling::*

    let $siblings := $precedingSiblings | $context | $followingSiblings
    
    return if ($width < string-length(string-join($siblings/text(), ''))) then
        let $sideCharCount := $width div 2
        let $cutPreceding := for $i in (1 to count($precedingSiblings)) return
                                if (string-length(string-join(subsequence($precedingSiblings, 1, $i), '')) >$sideCharCount) then
                                    $i
                                else ()
        let $cutFollowing := for $i in (1 to count($followingSiblings)) return
                                if (string-length(string-join(subsequence($followingSiblings, 1, $i), '')) >$sideCharCount) then
                                    $i
                                else ()
        let $cutPreceding := if (not(empty($cutPreceding[1]))) then $cutPreceding[1]
                             else 1
        let $cutFollowing := if (not(empty($cutFollowing[1]))) then $cutFollowing[1]
                             else 1
        
        return subsequence($precedingSiblings, 1, $cutPreceding) | $context | subsequence($followingSiblings, 1, $cutFollowing)
        
    else archaeo18lib:shorten-helper($context/.., $width - string-length(string-join($siblings/text(), '')))
};
--><xsl:template name="shorten"><xsl:param name="content" as="element()"/><xsl:param name="focus" as="xs:string"/><xsl:param name="length" as="xs:integer"/><xsl:variable name="focusNode" as="element()" select="$content//*[local-name(.) = $focus][1]"/><xsl:variable name="width" as="xs:integer" select="$length - string-length($focusNode/text())"/><xsl:choose><xsl:when test="$width &lt; 0"><xsl:value-of select="$focusNode"/></xsl:when><xsl:otherwise><xsl:call-template name="shorten-helper"><xsl:with-param name="context" select="$focusNode"/><xsl:with-param name="width" select="$width"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:template><xsl:template name="shorten-helper"><xsl:param name="context" as="element()"/><xsl:param name="width" as="xs:integer"/><xsl:variable name="precedingSiblings" select="$context/preceding-sibling::*"/><xsl:variable name="followingSiblings" select="$context/following-sibling::*"/><xsl:variable name="siblings" select="$precedingSiblings | $context | $followingSiblings"/><xsl:choose><xsl:when test="$width &lt; string-length(string-join($siblings/text(), ''))"><xsl:variable name="sideCharCount" select="$width div 2"/><xsl:variable name="cutPreceding"><xsl:for-each select="1 to count($precedingSiblings)"><xsl:if test="string-length(string-join(subsequence($precedingSiblings, 1, .), '')) &gt;$sideCharCount"><xsl:value-of select="."/></xsl:if></xsl:for-each></xsl:variable><xsl:variable name="cutFollowing"><xsl:for-each select="1 to count($followingSiblings)"><xsl:if test="string-length(string-join(subsequence($followingSiblings, 1, .), '')) &gt; $sideCharCount"><xsl:value-of select="."/></xsl:if></xsl:for-each></xsl:variable><xsl:variable name="cutPreceding"><xsl:choose><xsl:when test="not(empty($cutPreceding[1]))"><xsl:value-of select="$cutPreceding[1]"/></xsl:when><xsl:otherwise><xsl:value-of select="'1'"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="cutFollowing"><xsl:choose><xsl:when test="not(empty($cutFollowing[1]))"><xsl:value-of select="$cutFollowing[1]"/></xsl:when><xsl:otherwise><xsl:value-of select="'1'"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:value-of select="subsequence($precedingSiblings, 1, $cutPreceding) | $context | subsequence($followingSiblings, 1, $cutFollowing)"/></xsl:when><xsl:otherwise><xsl:call-template name="shorten-helper"><xsl:with-param name="context" select="$context/.."/><xsl:with-param name="width" select="$width - string-length(string-join($siblings/text(), ''))"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:template></xsl:stylesheet>