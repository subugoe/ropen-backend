xquery version "1.0";

module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib";

declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace exist="http://exist.sourceforge.net/NS/exist";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "./conf.xqm";

(: TODO:
        * add documentation
:)

declare function archaeo18lib:parse-facet($str as xs:string) as xs:string {
    (: let $teiNamespacePrefix := 'TEI:' :)
    (: This isn't really needed, the idea behind it that this should fail if this stuff was schema aware, but this isn't the case. :)
    let $facet := element {QName ('http://www.tei-c.org/ns/1.0', 
        if (lower-case(substring($str, 1, string-length($archeao18conf:teiNamespacePrefix))) = lower-case($archeao18conf:teiNamespacePrefix)) 
            then concat($archeao18conf:teiNamespacePrefix, substring($str, string-length($archeao18conf:teiNamespacePrefix) + 1))
        else concat($archeao18conf:teiNamespacePrefix, $str)
    )}{}
    return if ($archeao18conf:entities//TEI:*[local-name() = string(local-name($facet))]) then concat($archeao18conf:teiNamespacePrefix, local-name($facet))
           else ''
};

declare function archaeo18lib:parse-facets($str as xs:string) as xs:string* {
    for $f in archaeo18lib:search-split($str) return archaeo18lib:parse-facet($f)
    (: parse them and check if they are valid :)
    (:
    let $facets := if (matches($str, $archeao18conf:searchFacetSeperator)) then for $f in tokenize($str, $archeao18conf:searchFacetSeperator)
                   return (archaeo18lib:parse-facet($f))
                   else (archaeo18lib:parse-facet($str))
    return $facets
    :)
};

declare function archaeo18lib:get-page($ele as element()) as xs:integer {
    (: $searchSpace//TEI:p[@id=string($s/@id)]/preceding::TEI:pb[1] :)

    1
};

declare function archaeo18lib:filter-elements($element as element(), $remove as node(), $preserve as node()) as element() {
     let $element-name := local-name($remove)

     return
     element {QName (namespace-uri($element), name($element)) }
        { $element/@*,
            for $child in $element/node()
                return if ($child/*[local-name(.) = $element-name]//self::*[local-name(.) = $preserve]) then
                    if ($child instance of element()) then 
                        element { QName (namespace-uri($child), name($child)) } { $child/@*,
                            element { $preserve } {
                                    for $c in $child/node()[not(local-name(.) = $element-name)] return
                                    if ($c instance of element()) then
                                        archaeo18lib:filter-elements($c, $remove, $preserve)
                                    else $c
                                }
                                }
                     else ()
                else if ($child instance of comment()) then
                     ()
                else if ($child instance of element()) then
                    if (name($child) = $element-name or local-name($child) = $element-name) then
                         ()
                    else archaeo18lib:filter-elements($child, $remove, $preserve)
                else $child
           }
};

declare function archaeo18lib:copy-filter-elements($element as element(), $element-name as xs:string*) as element() {
     element {node-name($element) }
        { $element/@*,
            for $child in $element/node()[not(name(.)=$element-name)]
                return if ($child instance of element())
                        then archaeo18lib:copy-filter-elements($child,$element-name)
                    else $child
           }
}; 

declare function archaeo18lib:search-split($str as xs:string) as xs:string* {
    if (matches($str, $archeao18conf:searchFacetSeperator)) then for $f in tokenize($str, $archeao18conf:searchFacetSeperator)
    return $f
    else $str
};

declare function archaeo18lib:get-doc-name($str as xs:string) as xs:string {
    substring($str, 1, string-length($str) - string-length($archeao18conf:teiEnrichedSuffix))
};

declare function archaeo18lib:get-doc-display-name($str as xs:string) as xs:string {
    let $tei-enriched-location := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $str, '-enriched.xml')
    let $tei-enriched := doc($tei-enriched-location)
    let $title-short := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[@type = 'display']/text()
    return $title-short
};

declare function archaeo18lib:check-elements($str as xs:string, $elements as element()*) as xs:boolean {
    let $elementName := if (contains($str, ':')) then substring-after($str, ':')
                        else $str
    return if ($elements[local-name(.) = $elementName]) then true()
    else false()
};

declare function local:check-elements($str as xs:string*, $default as element()*, $elements as element()*) as element()* {
    let $elementNames := for $s in $str return
                         if (contains($s, ':')) then substring-after($s, ':')
                         else $s
    let $elements := for $e in $elementNames return
                     if ($elements[local-name(.) = $e]) then $elements[local-name(.) = $e]
                     else ()
    return if (count($elements) < 1) then $default
           else $elements
};

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

declare function archaeo18lib:build-search-path ($bases as xs:string*, $suffixes as xs:string*) as xs:string {
    string-join(for $b in $bases return
                    for $s in $suffixes return
                        concat($b, $s,
                            if ($suffixes[last()] != $s or $bases[last()] != $b) then '|'
                            else ''
                        )
     , '')
};


declare function archaeo18lib:generate-cloud ($text as node()*, $facets as xs:string*) as node() {
    let $facetPath := string-join(for $f in $facets
                                         return concat('$text//', $f, '/@ref'),
                                         '|')
    return <tags>{
        for $id in distinct-values(util:eval($facetPath))
        (:
        TODO: Add a check for the searches entity here instead of '*'
        :)
        let $entries  := $text//TEI:*[@ref=$id]
    
        let $name := if ($entries[1]/TEI:addName[@type = 'display']) then
                        $entries[1]/TEI:addName[@type = 'display']/text()
                     else
                        $entries[1]/text()
        (:Get rid of line breaks:)
        (:let $name := replace($name, '- &#xA;\s*', ''):)
        let $type := local-name($entries[1])
        let $links := archaeo18lib:resolve-identifiers($entries/@ref)
        
        (:
        order by count($entries) descending
        :)
        return 
        <tag> 
            <tag>{$name}</tag> 
            <facet>{concat(lower-case($archeao18conf:teiNamespacePrefix), $type)}</facet> 
            <count>{count($entries)}</count>
            {
                for $link in $links
                return <link>{$link}</link>
            
            }
            <pages> 
            {
                for $page in $entries
                let $variant := string(archaeo18lib:filter-elements($page, <TEI:addName/>, <exist:match/>))
                (:
                TODO: Check if this is correct, it depends on the order
                :)
                let $variant-without-hyphen := replace($variant, '-&#xA;\s*','')
                let $variant-clean := replace($variant-without-hyphen, '&#xA;\s*',' ')
                let $pageBreak-nr := data($page/preceding::TEI:pb[1]/@n)
                let $page-nr := if ($pageBreak-nr != '') then $pageBreak-nr
                                else 1
                return <page doc="{archaeo18lib:get-doc-id($page)}" variant="{$variant-clean}" n="{$page-nr}"/>
            }
            </pages> 
        </tag> 
    }</tags> 
};

declare function archaeo18lib:get-doc-id($i as item()) as xs:string {
    replace(util:document-name($i), '(.*?)-enriched.xml', '$1')
};

declare function archaeo18lib:resolve-identifiers ($ids as xs:string) as xs:string* {
    (: Split multiple IDs in one String :)
    let $ids := for $id in tokenize($ids, '\s*?#')
                return if ($id != '') then
                    $id
                else
                    ()
    
    let $prefixes := <prefixes>
                        <!--
                        <prefix name="dnb" uri="http://d-nb.info/gnd/" pattern=""/>
                        -->
                        <prefix name="getty" uri="http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=" pattern="GettyID:(\d{{7,8}})" start="GettyID"/>
                        <prefix name="cerl" uri="http://thesaurus.cerl.org/cgi-bin/record.pl?rid=" pattern="CerlID:(cn[pi]\d{{8,9}})" start="CerlID"/>
                        <prefix name="census" uri="http://census.bbaw.de/easydb/censusID=" pattern="CensusID:(\d{{9}})" start="CensusID"/>
                        <prefix name="http" uri="http" pattern="http(s?://.*)" start="http"/>
                        <!--
                        <prefix name="" uri="" pattern=""/>
                        -->
                     </prefixes>
    

    for $id in $ids
        let $prefix := $prefixes//prefix[@start = substring-before($id, ':')]
        return if (substring-after($id, ':') != '' and not(empty($prefix))) then
            let $link-id := replace($id, $prefix/@pattern, '$1')
            let $link := concat($prefix/@uri, $link-id)
            let $status := util:log('INFO', concat('Resolving identifier ', $id, ' to ', $link))
            return $link
        else
            ()
    
 
};


declare function archaeo18lib:filter-xslt ($element as element()*) as element()* {
    let $params := 
             <parameters>
                <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
             </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, 'lib/filter.xsl'))
    return transform:transform($element, $transform, $params)
};