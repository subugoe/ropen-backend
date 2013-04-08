xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

<places>{
    let $base := "/db/archaeo18/data/"
    let $teiPrefix := "tei/"
    let $suffix := "-enriched.xml"

    let $document := util:catch('*', request:get-parameter("doc",0), 'weimar-hs-2056')
                
    let $text := doc(concat($base, $teiPrefix, $document, $suffix))//TEI:text

    for $place in distinct-values($text//TEI:placeName) 
    let $placeEntries  := $text//*[TEI:placeName=$place]
    order by count($placeEntries) descending 
    return
        <entry>
            <place>{$place}</place>
            <count>{count($placeEntries)}</count>
        </entry>
}</places>