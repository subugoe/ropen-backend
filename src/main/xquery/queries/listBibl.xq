declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "./modules/conf.xqm";

<html>
<head></head>
<body>
{
    
    let $document := util:catch('*', request:get-parameter("doc", ''), '')

    let $text := if ($document != '') then doc(concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $document, $archeao18conf:teiEnrichedSuffix))//TEI:text
             else collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))
    (: This needs to return the complete XML Fragment, not only the text node:)
    for $biblRef in distinct-values($text//TEI:bibl/TEI:ref/@target)
        let $count := count($text//TEI:ref[@target = $biblRef])
        let $doc := substring(util:document-name($biblRef), 1, string-length($archeao18conf:teiEnrichedSuffix))
        order by count($text//TEI:ref[@target = $biblRef]) descending

    return
        <div class="biblEntry">
        <ul>
        {
            for $title in distinct-values($text//TEI:ref[@target = $biblRef])
                return <li>{$title}</li>
        
        }
        </ul>
        <span class="count">{$count}</span>
        <span class="doc">{$doc}</span>
        <a href="{$biblRef}">{$biblRef}</a>
        </div>

}</body></html>