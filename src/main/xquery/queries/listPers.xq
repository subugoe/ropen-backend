xquery version "1.0";

declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "./modules/conf.xqm";

<xhtml:html>
<xhtml:head></xhtml:head>
<xhtml:body>{
    
    let $document := util:catch('*', request:get-parameter("doc", ''), '')
    
    let $text := if ($document != '') then doc(concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $document, $archeao18conf:teiEnrichedSuffix))//TEI:text
             else collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))

    (: This needs to return the complete XML Fragment, not only the text node:)
    for $ref in distinct-values($text//TEI:persName)
    let $doc : = substring(util:document-name($ref), 1, string-length($archeao18conf:teiEnrichedSuffix))
    
    (:
    persName ref="#CerlID:cnp00984011" key="#PND:11862671X"
    :)
    
    return
        <xhtml:div class="date">
            <xhtml:span class="displayPersName">{$ref}</xhtml:span>
            <xhtml:span class="PND">{$ref/@key}</xhtml:span>
            <xhtml:span class="CERL">{$ref/@ref}</xhtml:span>
            <xhtml:span class="doc">{$doc}</xhtml:span>
        </xhtml:div>

}</xhtml:body></xhtml:html>