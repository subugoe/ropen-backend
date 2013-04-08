xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";

declare namespace a18enrich="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib" at "../modules/archaeo18lib.xqm";

declare function local:trim ( $arg as xs:string? )  as xs:string {
    replace(replace($arg,'\s+$',''),'^\s+','')
};

<a18enrich:results>{
let $cacheFileName := 'entityCache.xml'
let $cacheFile := concat($archeao18conf:cacheBase, $cacheFileName)
let $cache := doc($cacheFile)

let $query := util:catch('*', request:get-parameter("query", ''), '')
let $type := util:catch('*', request:get-parameter("type", ''), '')
let $mode := util:catch('*', request:get-parameter("mode", 'exact'), 'exact')

(: parse the facets :)
let $type := if ($type != '') then archaeo18lib:parse-facets($type)
             else ''
(:
let $entries := if ($type = '' and $mode = 'exact') then
                    $cache//entry[./name[. = string($query)]] | $cache//entry[./variant[. = string($query)]]
                else if (not(empty($type)) and $mode = 'exact') then
                    let $suffixes := for $t in $type
                                     return concat('[@type="', substring-after($t, ':'), '"]')
                    let $searchPath := archaeo18lib:build-search-path('$cache//entry[./name[.=string($query)]]', $suffixes) | archaeo18lib:build-search-path('$cache//entry[./variant[.=string($query)]]', $suffixes)
                    return util:eval($searchPath)
                else if ($type = '' and $mode = 'regexp') then
                    $cache//entry[./name[matches(., string($query), '')]] | $cache//entry[./variant[matches(., concat(string($query),'.*'), '')]]
                else
                    ()
:)
let $entries := if ($mode = 'exact') then
                    $cache//entry[./name[. = string($query)]] | $cache//entry[./variant[. = string($query)]]
                else if ($mode = 'case') then
                    $cache//entry[./name[lower-case(.) = lower-case(string($query))]] | $cache//entry[./variant[lower-case(.) = lower-case(string($query))]]
                else if ($mode = 'regexp') then
                    $cache//entry[./name[matches(., string($query), '')]] | $cache//entry[./variant[matches(., concat(string($query),'.*'), '')]]
                else
                    ()

let $status := util:log('INFO', concat('Query: "', $query, '", Type: "', string-join($type, ','), '", Mode: "', $mode, '"'))


let $results := for $entry in $entries
              let $matchType := if ($entry/name[. = string($query)]) then
                                    'exact'
                                else 'regexp'
              return if ($type = '' or ($type != '' and index-of($type, concat($archeao18conf:teiNamespacePrefix, $entry/@type)))) then
                    <a18enrich:result type="{$matchType}">
                        <a18enrich:id>{$entry/@id}</a18enrich:id>
                        <a18enrich:type>{$entry/@type}</a18enrich:type>
                        <a18enrich:match>{
                            if ($entry/name[. = string($query)]) then
                                $entry/name[. = string($query)]
                            else if ($entry/variant[. = string($query)]) then
                                $entry/variant[. = string($query)]
                            else if ($entry/name[matches(., string($query), '')]) then
                                distinct-values($entry/name[matches(., string($query), '')])
                            else if ($entry/variant[matches(., string($query), '')]) then
                                distinct-values($entry/variant[matches(., string($query), '')])
                            else ()
                        }</a18enrich:match>
                        
                     </a18enrich:result>
                     
                    else ()

return $results
}</a18enrich:results>