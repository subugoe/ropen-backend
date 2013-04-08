xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

<langs>{
    let $base := "/db/archaeo18/data/"
    let $teiPrefix := "tei/"
    let $suffix := "-enriched.xml"

    let $document := util:catch('*', request:get-parameter("doc",0), 'weimar-hs-2056')

    let $text := doc(concat($base, $teiPrefix, $document, $suffix))//TEI:text

    for $lang in distinct-values($text//TEI:foreign/@xml:lang)
    let $langEntries  := $text//TEI:foreign[@xml:lang=$lang]
    order by count($langEntries) descending
    return
        <entry>
            <lang>{$lang}</lang>
            <count>{count($langEntries)}</count>
        </entry>
}</langs>