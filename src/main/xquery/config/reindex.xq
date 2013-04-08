xquery version "1.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace ft="http://exist-db.org/xquery/lucene";

import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../queries/modules/conf.xqm";

let $login := xmldb:login($archeao18conf:base, $archeao18conf:user, $archeao18conf:password)

let $reindex := if ($archeao18conf:functionReindex = true()) then
                    xmldb:reindex($archeao18conf:base)
                else (false())
                
let $optimize := ft:optimize()

return <reindex>{$reindex}</reindex>