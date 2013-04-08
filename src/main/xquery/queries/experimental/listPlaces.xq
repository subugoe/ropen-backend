xquery version "1.0";

declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
(:
declare namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib";
:)

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib" at "../modules/archaeo18lib.xqm";

(:change this to a static value if you want to use alway use stream-transform() :)
let $streamTransform :=  if ($archeao18conf:httpIsRequest) then true()
                         else false()

let $document := util:catch('*', request:get-parameter("doc", ''), '')
let $facet := util:catch('*', request:get-parameter("facet", ''), '')
let $format := util:catch('*', request:get-parameter("format", 'kml'), 'kml')

let $text := if ($document != '') then 
                doc(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix))/*
             else
                collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))
 
 
return if ($format = 'kml') then
    let $places := for $place in $text//TEI:bibl
                   let $source-doc := archaeo18lib:get-doc-name(util:document-name($place))
                   return element { node-name($place)}
                    {  attribute {'archaeo18lib:source-document'} {$source-doc}, $place/@*,
                    $place/node() }
    

    let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetKml))
   (:
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
        :)

    return $places

else ()