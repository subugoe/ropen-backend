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
    for $termRef in distinct-values($text//TEI:term/@ref)
        let $count := count($text//TEI:term[@ref=$termRef])
        order by count($text//TEI:term[@ref=$termRef]) descending
    
    return
        (: TODO:
                * the additional names aren't removed yet.        
        :)
        <xhtml:div class="term"> <xhtml:ul>{
            for $name in distinct-values($text//TEI:term[@ref=$termRef][local-name(.) != 'addName'])
                return <xhtml:li>{$name}</xhtml:li>
        }</xhtml:ul>
        <xhtml:a href="{$termRef}">{$termRef}</xhtml:a>
        <xhtml:span class="count">{$count}</xhtml:span>
        </xhtml:div>
        

}</xhtml:body></xhtml:html>