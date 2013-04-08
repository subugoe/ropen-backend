xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace transform="http://exist-db.org/xquery/transform";

import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";


let $document := util:catch('*', request:get-parameter("doc", 'bern-mss-muel-507'), '')

let $file := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix)
let $header := doc($file)//TEI:teiHeader

return $header
