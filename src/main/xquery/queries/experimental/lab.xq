xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace transform="http://exist-db.org/xquery/transform";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";

declare option exist:serialize "method=xml media-type=text/xml";

let $document := util:catch('*', request:get-parameter("doc", 'rom-heyne1798'), 'rom-heyne1798')
let $lab := util:catch('*', request:get-parameter("lab", 'e4d'), 'e4d')

let $file := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix)
let $text := doc($file)/*

let $transform := if ($lab = 'e4d' or $lab = 'e4d2') then 
                        doc(concat($archeao18conf:transformationsBase, 'gettyQuery.xsl'))
                   else ()

let $normalize := if ($lab = 'e4d2') then 
                        true()
                  else false()

let $format := 'kml'
let $pageAsYear := true()

let $params := 
<parameters>
   <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
   (: Needed for KML export :)
   <param name="identifier" value="{$document}"/>
   (: Needed for structure extractor :)
   <param name="output" value="{$format}"/>
   <param name="pageAsYear" value="{$pageAsYear}"/>
   <param name="normalize" value="{$normalize}"/>
</parameters>

return if ($lab = 'e4d' or $lab = 'e4d2') then
        transform:transform($text, $transform, $params)
    else
        $text
