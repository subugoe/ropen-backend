xquery version "1.0";

declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "./modules/conf.xqm";
import module namespace strings = "http://archaeo18.sub.uni-goettingen.de/exist/strings" at "./modules/strings.xqm";
import module namespace date = "http://archaeo18.sub.uni-goettingen.de/exist/date" at "./modules/date.xqm";

<xhtml:html>
<xhtml:head></xhtml:head>
<xhtml:body>{

    let $document := util:catch('*', request:get-parameter("doc", ''), '')
    
    let $text := if ($document != '') then doc(concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $document, $archeao18conf:teiEnrichedSuffix))//TEI:text
             else collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))

    (: This needs to return the complete XML Fragment, not only the text node:)
    for $ref in distinct-values($text//TEI:date)
    (: Here is some more logic needed for years smaller then 1000 and for combined dates(day, month, year) :)
    let $doc : = substring(util:document-name($ref), 1, string-length($archeao18conf:teiEnrichedSuffix))
    let $add := <xhtml:span class="doc">{$doc}</xhtml:span>
    return date:date-entry ($ref, $add)
        

}</xhtml:body></xhtml:html>