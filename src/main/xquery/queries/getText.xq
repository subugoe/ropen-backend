xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace exsl="http://exslt.org/common";
declare namespace system="http://exist-db.org/xquery/system";

import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";
import module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib" at "modules/archaeo18lib.xqm";
import module namespace lib="http://sub.uni-goettingen.de/exist/lib" at "modules/lib.xqm";

declare option exist:serialize "method=xml media-type=text/xml";

(: TODO:
 * Return documentation.
 * Get rid of first and last pagebreak is fragments are displayed
 * add a simple cache
 * Add highlighting in text - implementet but doesn't work yet
 * It should be possible to get paragraphs and divs by Id - works
:)

(:~
 : This query returns a transformed representation of the specified document
 :
 : @author cmahnke
 :
 : @param $document the internal identifier of the document to be transformed
 : @return a XML document in the specified format
 :)

(:change this to a static value if you want to use alway use stream-transform() :)
let $streamTransform :=  if ($archeao18conf:httpIsRequest) then true()
                         else false()

let $document := util:catch('*', request:get-parameter("doc", 'rom-heyne1798'), 'rom-heyne1798')
let $page := util:catch('*', request:get-parameter("page", 0), 0)
let $mode := util:catch('*', request:get-parameter("mode", 'text'), 'text')
let $format := util:catch('*', request:get-parameter("format", 'tei'), 'tei')
let $pageEnd := util:catch('*', request:get-parameter("pageEnd", 0), 0)
let $highlight := lower-case(util:catch('*', request:get-parameter("highlight", 'true'), 'true'))
let $query := util:catch('*', request:get-parameter("query", ''), '')
let $id := util:catch('*', request:get-parameter("id", ''), '')
let $facet := util:catch('*', request:get-parameter("facet", ''), '')

let $file := concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix)
(:
let $text := doc($file)/*
:)
let $text := doc($file)

let $transform := if ($mode = 'text' and $format = 'tei') then 
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetBreak))
                    else if ($mode = 'text' and $format = 'kml') then 
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetKml))
                    else if ($mode = 'structure') then
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetStructure))
                    else if ($format = 'cloud') then
                        ()
                    else if ($format = 'xhtml') then
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetXhtml))
                    (:
                    else if ($mode = 'header' and $format = 'xhtml') then
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetXhtml))
                    else if ($mode = 'raw' or $mode = 'text' and $format = 'xhtml') then
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetXhtml))
                    else if ($mode = 'line' and $format = 'xhtml') then
                        doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetXhtml))
                    :)
                    else if ($mode = 'raw' or $mode = 'header' and $format = 'tei') then
                    (: Just use a empty node set to indicate there shouldn't be any transformation (raw mode) :)
                        ()
                    else ()

(: Find start page for given ID:)
let $page-nr-start := if ($id != '') then
                        xs:integer($text//TEI:*[@id = $id]/preceding::TEI:pb[1]/@n)
                        (:
                        count($text//TEI:*[@id = $id]/preceding::TEI:pb)
                        :)
                    (: sanitize input :)
                    else if ($page castable as xs:integer and xs:integer($page) != 0) then
                        xs:integer($page)
                    else
                        0

let $page-nr-end := if ($page castable as xs:integer and xs:integer($pageEnd) != 0) then
                    xs:integer($pageEnd)
                  else if ($page-nr-start = 0) then
                    0
                  else if ($id != '' and $page castable as xs:integer and xs:integer($page) = -1) then
                    0
                  else
                    $page-nr-start + 1


let $highlight := if ($highlight = 'false' or $highlight = '0')
              then false()
              else true()  

(: parse the facets :)
let $facets := if ($facet != '') then archaeo18lib:parse-facets($facet)
               else ()

let $query := lib:clear-query($query)

(: Log request :)
let $status := util:log('INFO', concat('Document: "', $document, '", Start page: "', $page-nr-start, '" End page: "', $page-nr-end, '", Format: "', $format, '", Mode: ', $mode, '", Query: "', $query, '", ID: ', $id, '"'))

(:This is needed to highlight matches - first search if result is empty jus use the normal fragment:)

let $search-fragment := if (not(empty($query)) and $query != '') then
                            $text//TEI:div[ft:query(., $query)][TEI:pb[@n = $page-nr-start] and TEI:pb[@n = $page-nr-end]][1]
                        else
                            ()

let $search-fragment := if (not(empty($search-fragment))) then
                            archaeo18lib:filter-elements(util:expand($search-fragment), <TEI:addName/>, <exist:match/>)
                        else
                            ()

(: get the fragment to display :)
let $fragment := if ($page-nr-start = 0 and $page-nr-end = 0 and not(empty($document)) and $id = '' and $mode != 'header') then
                    $text
                 else if (not(empty($document)) and $mode = 'header') then
                    $text//TEI:teiHeader
                 (: Just return the element with the given ID :)
                 else if (not(empty($document)) and $id != '' and $page-nr-end = 0) then
                    $text//*[@id = $id]
                 else if (not(empty($document))) then
                    (: check if the fixed function can be used, otherwise use the slow one :)
                    if (starts-with(system:get-version(), '1.4')) then
                        lib:milestone-chunk-ns(($text//TEI:pb)[$page-nr-start], ($text//TEI:pb)[$page-nr-end], $text)
                    else if (starts-with(system:get-version(), '1.5')  or starts-with(system:get-version(), '2')) then
                        util:parse(util:eval('util:get-fragment-between(($text//TEI:pb)[$page-nr-start], ($text//TEI:pb)[$page-nr-end], true(), true())'))
                    else lib:milestone-chunk-ns(($text//TEI:pb)[$page-nr-start], ($text//TEI:pb)[$page-nr-end], $text)
                    
                else ()
                
let $status := util:log('DEBUG', $fragment)


let $lineMode := if ($mode = 'line') then true()
                else false()

let $params := 
<parameters>
   <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
   (: Needed for KML export :)
   <param name="identifier" value="{$document}"/>
   (: Needed for structure extractor :)
   <param name="output" value="{$format}"/>
   <param name="output-param" value="{$format}"/>
   <param name="line-mode-param" value="{$lineMode}"/>
</parameters>

let $this := ''

let $status := if (not(empty($transform))) then
                    util:log('DEBUG', concat('Transformation: ', util:document-name($transform)))
                else
                    util:log('DEBUG', 'No transformation!')

return if (empty($document)) then
            ()
            (: TODO: This doesn't work in exist 2.0
            <doc><file>{$this}</file>{util:extract-docs($this)}</doc>
            :)
       else if (not(empty($transform))) then
            if ($streamTransform = true()) then
                (: transform:stream-transform is faster :)
                transform:stream-transform($fragment, $transform, $params)
            else
                transform:transform($fragment, $transform, $params)
       else if ($format = 'cloud') then
            archaeo18lib:generate-cloud($fragment, $facets)
       else
            $fragment
