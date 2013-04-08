xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "./modules/conf.xqm";

declare default collation "?lang=de-DE"; 

<cloud>{
    let $base := $archeao18conf:dataBase
    let $teiPrefix := $archeao18conf:teiPrefix
    let $teiEnrichedPrefix := $archeao18conf:teiEnrichedPrefix
    let $suffix := $archeao18conf:teiEnrichedSuffix
    let $transformationRESTBase := $archeao18conf:transformationRestBase

    let $document := util:catch('*', request:get-parameter("doc", ''), '')
    
    let $text := if ($document != '') then doc(concat($base, $teiPrefix, $document, $suffix))//TEI:text
             else collection(concat($archeao18conf:dataBase, $teiEnrichedPrefix))
    
    let $cerlPrefix := "http://thesaurus.cerl.org/record/"

    for $id in distinct-values($text//TEI:persName/@ref)
    let $personEntries  := $text//TEI:persName[@ref=$id]
    (: This isn't complete clean yet, there might be tags and linebreaks in the names, too :)
    (: this also doesn't handle persons without identifier :)
    (: let $personName := replace(($personEntries[1]/text()), '- \n', '') :)
    let $personName := $personEntries[1]/text()
    let $cerlLink := if ( matches($id, '#CerlID:.*') =  true())
                then concat($cerlPrefix, replace($id, '#CerlID:', ''))
                else ''
                
    order by count($personEntries) descending
 
    return
        <cloudEntry>
            <id>{$id}</id>
            <count>{count($personEntries)}</count>
            <name>{$personName}</name>
            <cerlLink>{$cerlLink}</cerlLink>
        </cloudEntry>
}</cloud>