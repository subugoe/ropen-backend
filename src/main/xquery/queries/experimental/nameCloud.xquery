xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib" at "../modules/archaeo18lib.xqm";


declare default collation "?lang=de-DE"; 

declare function local:generate-cloud ($text as node()*, $facets as xs:string*) as node() {
    let $facetPath := string-join(for $f in $facets
                                         return concat('$text//', $f, '/@ref'),
                                         '|')

    return <tags prefix="{lower-case($archeao18conf:teiNamespacePrefix)}">{
        for $id in distinct-values(util:eval($facetPath))
        (:
        TODO: Add a check for the searches entity here instead of '*'
        :)
        let $entries := $text//TEI:*[@ref=$id]
    

        (:Get rid of line breaks:)

        let $type := local-name($entries[1])
        
        (:
        order by count($entries) descending
        :)
        return 
        <tag> 
            <pages> 
            {
                for $page in $entries
                return <page doc="{archaeo18lib:get-doc-id($page)}" n="{data($page/preceding::TEI:pb[1]/@n)}">
                    {$page}
                </page>
            }
            </pages> 
        </tag> 
    }</tags> 
};


let $facet := util:catch('*', request:get-parameter("facet", ''), '')
let $document := util:catch('*', request:get-parameter("doc", ''), '')

(: parse the facets :)
let $facets := if ($facet != '') then archaeo18lib:parse-facets($facet)
               else ()

(: check if we should search inside a specific document or in the whole colection :)
let $text := if ($document != '') then 
                doc(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix))/*
             else
                collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))

let $cloud := local:generate-cloud($text, $facets)

return $cloud