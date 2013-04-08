xquery version "1.0";

declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib" at "../modules/archaeo18lib.xqm";


(:change this to a static value if you want to use alway use stream-transform() :)
let $streamTransform :=  if ($archeao18conf:httpIsRequest) then true()
                         else false()

let $document := util:catch('*', request:get-parameter("doc", ''), '')
let $facet := util:catch('*', request:get-parameter("facet", ''), '')
let $format := util:catch('*', request:get-parameter("format", 'xhtml'), 'xhtml')

(: Should the entities be unique per page? :)
let $distict := true()

(: parse the facets :)
let $facets := if ($facet != '') then archaeo18lib:parse-facets($facet)
               else ()

(:
TODO:
 * check if facet is place if format is kml
:)
(: check if we should search inside a specific document or in the whole colection :)
let $text := if ($document != '') then 
                doc(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix))/*
             else
                collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))
 
            
return if ($format = 'xhtml2') then
    (: calculate the facet base search strings :)
    let $facetPath := string-join(for $f in $facets
                                         return concat('$text//', $f), '|')
    let $status := util:log('DEBUG', concat('Facet path: ', $facetPath))
    let $entries := util:eval($facetPath)
    (:TODO: Make the captions configurable:)
    return 
    <html xhtml="http://www.w3.org/1999/xhtml">
    <head></head>
    <body>
    <table>
        <thead>
            <tr>
                <td><span xml:lang="de">Entitätsbezeichnung</span><span xml:lang="en">Entity</span></td>
                <td><span xml:lang="de">Handschrift</span><span xml:lang="en">Manuscript</span></td>
                <td><span xml:lang="de">Seitenlink</span><span xml:lang="en">Page link</span></td>
            </tr>
        </thead>
        <tbody>{
            for $entry in $entries
            let $pageNr := $entry/preceding::TEI:pb[1]/@n
            
            let $name := (: This is needed to use the display name, not the canonical one
                        if ($entry/TEI:addName[@type = 'display']) then
                            $entry/TEI:addName[@type = 'display']/text()
                        else
                        :)
                            string(archaeo18lib:filter-elements($entry, <TEI:addName/>, <exist:match/>))
            let $name := replace($name, '-\s*', '')
     
            let $name-link := if ($entry/@ref) then
                                <a target="_blank" href="{archaeo18lib:resolve-identifiers($entry/@ref)}">
                                    {$name}
                                </a>
                              else
                                $name
            (:
            order by $name descending
            :)
            return
                <tr>
                <td>
                    {$name-link}
                </td>
                <td>{archaeo18lib:get-doc-name(util:document-name($entry))}</td>
                <td class="pagelink"><a>{data($pageNr)}</a></td></tr>
    }</tbody>
    <tfoot>
        <tr>
             <td><span xml:lang="de">Entitätsbezeichnung</span><span xml:lang="en">Entity</span></td>
             <td><span xml:lang="de">Handschrift</span><span xml:lang="en">Manuscript</span></td>
             <td><span xml:lang="de">Seitenlink</span><span xml:lang="en">Page link</span></td>
        </tr>
    </tfoot>
    </table></body></html>
else if ($format = 'xhtml') then   
    let $cloud := archaeo18lib:generate-cloud($text, $facets)
    let $transform := doc(concat($archeao18conf:transformationsBase, 'cloud.xsl'))
    let $params := 
        <parameters>
           <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
        </parameters>
    return if ($streamTransform = true()) then
        (: transform:stream-transform is faster :)
        transform:stream-transform($cloud, $transform, $params)
    else
        transform:transform($cloud, $transform, $params)
    
else if ($format = 'cloud') then
    archaeo18lib:generate-cloud($text, $facets)
else if ($format = 'kml') then
    let $places := for $place in $text//TEI:placeName
                   let $source-doc := archaeo18lib:get-doc-name(util:document-name($place))
                   (:
                   Siehe http://www.xqueryfunctions.com/xq/functx_add-attributes.html
                   :)
                   return element { node-name($place)}
                    {  attribute {'archaeo18lib:source-document'} {$source-doc}, $place/@*,
                    $place/node() }
    
    let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetKml))
    let $fragment := $places

    let $params := 
        <parameters>
           <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
           (: Needed for KML export :)
           <param name="identifier" value="{$document}"/>
           (: Needed for structure extractor :)
           <param name="output" value="{$format}"/>
        </parameters>
    return if ($streamTransform = true()) then
        (: transform:stream-transform is faster :)
        transform:stream-transform($fragment, $transform, $params)
    else
        transform:transform($fragment, $transform, $params)

else 
()
