xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";

let $base := '/db/archaeo18/data/'
let $teiPrefix := 'tei/'
let $teiEnrichedPrefix := 'tei-enriched/'
let $suffix := "-enriched.xml"

let $document := util:catch('*', request:get-parameter("doc", 'weimar-hs-2056'), 'weimar-hs-2056')
let $file := concat($base, $teiEnrichedPrefix, $document, $suffix)
let $text := doc($file)
 
let $count := count($text//TEI:pb)

return
    <pages>
    <doc>{$document}</doc>
    <count>{$count}</count>
    </pages>

