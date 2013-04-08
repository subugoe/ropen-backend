xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace strings = "http://archaeo18.sub.uni-goettingen.de/exist/strings" at "../modules/strings.xqm";
import module namespace a18enr="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment" at "../modules/archaeo18enrichment.xqm";

declare variable $local:mode := util:base-to-integer(0755, 8);

let $searchCollection := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix)
let $documentBase := collection($searchCollection)/*

let $cacheFileName := 'entityCache.xml'
let $cacheFile := concat($archeao18conf:cacheBase, $cacheFileName)


let $wordIndexFileName := 'wordIndex.xml'
let $wordIndexFile := concat($archeao18conf:cacheBase, $cacheFileName)

let $cacheHeader := <metadata>
                        <collection>{$searchCollection}</collection>
                        <cacheFile>{$cacheFile}</cacheFile>
                        <date>{current-date()}</date>
                    </metadata>
                    
let $wordIndex := for $entry in doc($cacheFile)//entry
                    let $status := util:log('DEBUG', concat('Processing ', $entry/@id))
                    let $words := for $word in $entry//name | $entry//variant
                                  return strings:trim(a18enr:normalize-name($word))
                    
                  return for $word in distinct-values($words)
                         return <word id="{$entry/@id}" type="{$entry/@type}"
                         wordCount="{strings:word-count($word)}"
                         start="{tokenize($word, '\s')[1]}">{$word}</word>



let $wordIndexContent := <wordIndex>{($cacheHeader, $wordIndex)}</wordIndex>

let $status := util:log('DEBUG', 'Storing word index content')
let $login := xmldb:login($archeao18conf:dataBase, $archeao18conf:user, $archeao18conf:password)
let $backup := xmldb:rename($archeao18conf:cacheBase, $wordIndexFileName, concat($wordIndexFileName, '.bak')) 
let $cacheStore := xmldb:store($archeao18conf:cacheBase, $wordIndexFileName, $wordIndexContent)
let $chmod := xmldb:chmod-collection($archeao18conf:cacheBase, $local:mode)

return $wordIndexContent 