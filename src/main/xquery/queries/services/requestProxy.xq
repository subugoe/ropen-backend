xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace httpclient = "http://exist-db.org/xquery/httpclient";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";

declare function local:create-cache-file ($collection as xs:string, $file as xs:string) as xs:boolean {
    let $cache := <cache><created date="{current-dateTime()}"/></cache>
    let $store := xmldb:store($collection , $file, $cache)
    return true()
};

declare function local:get-url ($url as xs:anyURI, $cacheFile as xs:string) as element() {
    (: TODO: Add check for age of cache entry :)
    
    let $headers := <headers></headers>
    let $resultNode := if (document($cacheFile)//cacheEntry[@url = $url]) then document($cacheFile)//cacheEntry[@url = $url]/*
                        else httpclient:get($url, false(), $headers)//httpclient:body/*
    let $cacheEntry := <cacheEntry url="{$url}" date="{current-dateTime()}">{$resultNode}</cacheEntry>
    let $change :=  if (not(document($cacheFile)//cacheEntry[@url = $url])) then
                          update insert $cacheEntry into document($cacheFile)/cache
                    else false ()
    
    return $resultNode
};

let $base := '/db/archaeo18/data/'
let $tmp := 'tmp/'
let $cache := 'requestCache.xml'
let $maxAge := 1440

let $url := util:catch('*', request:get-parameter("url", ''), "")
let $login := xmldb:login(concat($base, $tmp), archeao18conf:user(), archeao18conf:password())

let $create := if (not(doc-available(concat($base, $tmp, $cache)))) 
                then local:create-cache-file(concat($base, $tmp), $cache) else false()
(:
* Look into cache file
* if found, return entry
* else request document
* write to cache

:)
return if (not($url)) then (
    <error>
        <message>URL is missing!</message> 
    </error>
) else
local:get-url(xs:anyURI($url), concat($base, $tmp, $cache))