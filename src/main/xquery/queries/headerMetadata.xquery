xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
        
import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";

let $document := util:catch('*', request:get-parameter("doc",0), '')
                
let $text := let $text := if ($document != '') then 
                            doc(concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $document, $archeao18conf:teiEnrichedSuffix))//TEI:teiHeader
                          else
                            ()


return $text
