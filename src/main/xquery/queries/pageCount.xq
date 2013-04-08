declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace ft="http://exist-db.org/xquery/lucene";


let $base := '/db/archaeo18/data/'
let $teiPrefix := 'tei/'
let $teiEnrichedPrefix := 'tei-enriched/'
let $suffix := "-enriched.xml"

let $document := util:catch('*', request:get-parameter("doc", 'rom-heyne1798'), 'rom-heyne1798')

let $file := concat($base, $teiEnrichedPrefix, $document, $suffix)
    let $text := doc($file)
    let $count := string(($text//TEI:pb[last()])[last()]/@n)
    
    return 
    <pages>
    <doc>{$document}</doc>
    <count>{$count}</count>
    </pages>

