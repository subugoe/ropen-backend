xquery version "1.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace METS="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";

import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes encoding=UTF-8";

let $document := util:catch('*', request:get-parameter("doc", ''), '')

return if ($document != '' and doc-available(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, '-enriched.xml'))) then
    let $id := $document
    let $tei-enriched-location := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $id, '-enriched.xml')
    let $tei-enriched := doc($tei-enriched-location)
    let $title := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]/text()
    let $title-short := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[@type = 'display']/text()
    let $metsFile := concat($archeao18conf:dataBase, $archeao18conf:metsPrefix, $id, '.mets.xml')
    let $preview := data(doc($metsFile)//METS:fileGrp[@USE = 'MIN']//METS:file[1]/METS:FLocat/@xlink:href)        
    let $tei-location := concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $id, '.xml')
    let $pageCount := count($tei-enriched//TEI:pb)
    return 
        <docs><doc>
            <id>{$id}</id>
            <title>{$title}</title>
            <titleShort>{$title-short}</titleShort>
            <preview>{$preview}</preview>
            <tei>{$tei-location}</tei>
            <teiEnriched>{$tei-enriched-location}</teiEnriched>
            <mets>{$metsFile}</mets>
            <pageCount>{$pageCount}</pageCount>
        </doc></docs>
else 
<docs>{
    let $tei := xmldb:get-child-resources(concat($archeao18conf:dataBase, $archeao18conf:teiPrefix))
    let $mets := xmldb:get-child-resources(concat($archeao18conf:dataBase, $archeao18conf:metsPrefix))
    for $doc in $tei[matches(., '\d.xml')]
            let $id := replace($doc, '.xml', '')
            let $tei-enriched-location := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $id, '-enriched.xml')
            let $tei-enriched := doc($tei-enriched-location)
            let $title := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[not(@type = 'display')]/text()
            let $origDate := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:sourceDesc/TEI:msDesc/TEI:history/TEI:origin/TEI:origDate/text()
            let $title-short := $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title[@type = 'display']/text()
            let $metsFile := concat($archeao18conf:dataBase, $archeao18conf:metsPrefix, $id, '.mets.xml')
            let $preview := data(doc($metsFile)//METS:fileGrp[@USE = 'MIN']//METS:file[1]/METS:FLocat/@xlink:href)        
            let $tei-location := concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $id, '.xml')
            let $pageCount := count($tei-enriched//TEI:pb)
    
            (: This orders the documents by publication date :)
            order by $tei-enriched/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:sourceDesc/TEI:msDesc/TEI:history/TEI:origin/TEI:origDate/text()
            
            return 
                <doc>
                    <id>{$id}</id>
                    <title>{$title}</title>
                    <titleShort>{$title-short}</titleShort>
                    <preview>{$preview}</preview>
                    <tei>{$tei-location}</tei>
                    <teiEnriched>{$tei-enriched-location}</teiEnriched>
                    <mets>{$metsFile}</mets>
                    <pageCount>{$pageCount}</pageCount>
                    <origDate>{$origDate}</origDate>
                </doc>
}</docs>