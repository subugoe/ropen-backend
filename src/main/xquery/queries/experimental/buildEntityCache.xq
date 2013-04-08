xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace strings = "http://archaeo18.sub.uni-goettingen.de/exist/strings" at "../modules/strings.xqm";
import module namespace a18enr="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment" at "../modules/archaeo18enrichment.xqm";


declare variable $local:mode := util:base-to-integer(0755, 8);

declare function local:remove-elements($input as element(), $remove-names as xs:string*) as element() {
   element {node-name($input) }
      {$input/@*,
       for $child in $input/node()[not(name(.) = $remove-names)]
          return
             if ($child instance of element())
                then local:remove-elements($child, $remove-names)
             else if ($child instance of comment())
                then ()
             else $child
      }
};

declare function local:clean-name ($arg as xs:string?) as xs:string {
  let $normilize-space := strings:trim(replace($arg, '\s+', ' '))
  return ($normilize-space, if (not(contains($normilize-space, '- '))) then (replace($normilize-space, '-\s+', ' '))
                            else ())
};

declare function local:normalize-name ($args as xs:string*) as xs:string* {
    for $arg in $args
        let $clean := replace(replace($arg, '\W', ' '), '\s+', ' ')
        let $lc := lower-case($clean)
    return $lc
};

declare function local:get-docs ($entries as element()*) as element()* {
    let $documents :=  for $entry in $entries
                       return util:document-name($entry)
    for $doc in distinct-values($documents)
    return <document>{$doc}</document>
};

declare function local:get-name ($entry as element()) as xs:string* {
    let $nameString := string(local:remove-elements ($entry, 'addName'))
    return if (not(contains($nameString, '- '))) then (replace($nameString, '\s+', ' '))
           else (replace($nameString, '\s+', ' '), replace($nameString, '-\s+', ''))
};

declare function local:get-names ($entries as element()*) as element()* {
    let $names := for $entry in $entries
                  return local:get-name($entry) 
    let $nameEntries := for $name in distinct-values($names)
                            let $count := count($names[. = $name])
                        return <name occurences="{$count}" wordCount="{strings:word-count($name)}" charCount="{string-length($name)}">{$name}</name>

    let $normalizedEntries := for $n in distinct-values($names)
                                return for $name in local:normalize-name($n)
                                    return <normalized wordCount="{strings:word-count($name)}" charCount="{string-length($name)}">{$name}</normalized>
                              
    return ($nameEntries, $normalizedEntries)
};

declare function local:build-cache-entry ($entries as element()*) as element() {
    let $id := data($entries[1]/@ref)
    let $type := local-name($entries[1])
    let $status := util:log('DEBUG', concat('Processing ID: ', $id))

    let $nameEnties := local:get-names($entries)                     
    let $docEntries := local:get-docs($entries)
    
    let $variants := if ($entries//TEI:addName) then
                        for $addName in distinct-values($entries//TEI:addName)
                        return <variant wordCount="{strings:word-count($addName)}"  charCount="{string-length($addName)}">{$addName}</variant>
                     else ()
    
    return <entry type="{$type}" id="{$id}">{
              ($nameEnties, $variants, $docEntries)
           }</entry>
};


let $searchCollection := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix)
let $documentBase := collection($searchCollection)/*

let $cacheFileName := 'entityCache.xml'
let $cacheFile := concat($archeao18conf:cacheBase, $cacheFileName)

let $cacheHeader := <metadata>
                        <collection>{$searchCollection}</collection>
                        <cacheFile>{$cacheFile}</cacheFile>
                        <date>{current-date()}</date>
                    </metadata>

let $refCache := for $ref in distinct-values(data($documentBase//TEI:*[@ref]/@ref))
                 return if ($ref != '#GettyID:' and $ref != '#CerlID:cnp' and $ref != '#') then
                            local:build-cache-entry($documentBase//TEI:*[@ref = $ref])
                        else
                            ()

let $biblCache := for $target in distinct-values(data($documentBase//TEI:bibl/TEI:ref[@target]/@target))
    let $entries := $documentBase//TEI:*[@target = $target]
    
    let $id := data($entries[1]/@target)
    let $type := local-name($entries[1])
    let $status := util:log('DEBUG', concat('Processing ID: ', $id))

    return if ($target != '#') then 
                let $nameEnties := local:get-names($entries)                     
                let $docEntries := local:get-docs($entries)
                return <entry type="{$type}" id="{$id}">{
                          ($nameEnties, $docEntries)
                       }</entry>
           else
                ()

let $cacheContent := <cache>{($cacheHeader, $refCache, $biblCache)}</cache>

let $status := util:log('DEBUG', 'Storing cache content')
let $login := xmldb:login($archeao18conf:dataBase, $archeao18conf:user, $archeao18conf:password)
let $backup := xmldb:rename($archeao18conf:cacheBase, $cacheFileName, concat($cacheFileName, '.bak')) 
let $cacheStore := xmldb:store($archeao18conf:cacheBase, $cacheFileName, $cacheContent)
let $chmod := xmldb:chmod-collection($archeao18conf:cacheBase, $local:mode)

return $cacheContent 
