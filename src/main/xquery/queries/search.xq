xquery version "1.0";
declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace transform="http://exist-db.org/xquery/transform";

import module namespace kwic="http://exist-db.org/xquery/kwic";

import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";
import module namespace archaeo18lib="http://archaeo18.sub.uni-goettingen.de/exist/archaeo18lib" at "modules/archaeo18lib.xqm";
import module namespace lib="http://sub.uni-goettingen.de/exist/lib" at "modules/lib.xqm";

(: TODO: Remove this, it's needed for the huge hits (<div/> elements) :)

declare option exist:output-size-limit "-1";

(:
TODO
* mode: suggestions - works, but slow
* show hits in facetted search
* Check if pagenumbers work for hits in facests and headings
* make the searchspace (TEI:p vs. TEI:div vs. TEI:text) configurable
* list all matches for a given facets if no query is entered
* add documentation
* add a timer - done
:)

(: Timer :)
let $timerStart := util:system-time()
(:simple configuration of searchable items:)
(: <TEI:div/>, <TEI:text/> :)
let $searchableElements := (<TEI:p/>, <TEI:head/>)

(: These will be searched by default :)
(: Added div, see https://jira.bibforge.org/jira/browse/ARCH-302 :)
let $defaultSearchElements := (<TEI:p/>, <TEI:head/>)

let $document := util:catch('*', request:get-parameter("doc", ''), '')
let $query := util:catch('*', request:get-parameter("query", ''), '')
let $filter := lower-case(util:catch('*', request:get-parameter("filter", 'true'), 'true'))
let $highlight := lower-case(util:catch('*', request:get-parameter("highlight", 'true'), 'true'))
let $start := util:catch('*', request:get-parameter("start", 0), 0)
let $limit := util:catch('*', request:get-parameter("limit", 0), 0)
let $facet := util:catch('*', request:get-parameter("facet", ''), '')
let $mode := util:catch('*', request:get-parameter("mode", $archeao18conf:searchDefaultMode), $archeao18conf:searchDefaultMode)
let $summary := util:catch('*', request:get-parameter("summary", 0), 0)

(: Other configuration :)
let $serialization := 'xquery'

(: Set up XSLT transformation :)
let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetXhtml))
let $params := <parameters>
                   <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
               </parameters>

(: parse the facets :)
let $facets := if ($facet != '') then archaeo18lib:parse-facets($facet)
               else ()

(: check if we should search inside a specific document or in the whole colection :)
let $searchSpace := if ($document != '') then
                        doc(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix, $document, $archeao18conf:teiEnrichedSuffix))/*
                    else
                        collection(concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))
             
(:check mode :)             
let $mode := if (index-of(('statistics', 'xhtml', 'suggestion'), $mode)) then $mode
             else $archeao18conf:searchDefaultMode
             
(: sanitize input :)
let $start := if ($start castable as xs:integer) then xs:integer($start)
              (: Always start at the beginning for suggestions :)
              else if ($mode = 'suggesion') then 0
              else 0

let $limit := if ($limit castable as xs:integer) then xs:integer($limit)
              (: Always limit for suggestions :)
              else if ($mode = 'suggesion') then $archeao18conf:searchSuggesionLimit
              else 0
              
let $filter := if ($filter = 'false' or $filter = '0')
              then false()
              else true()
              
let $highlight := if ($highlight = 'false' or $highlight = '0')
              then false()
              else true()             

let $summary := if ($summary castable as xs:integer) then xs:integer($summary)
              (: Always limit for suggestions :)
              else if ($mode = 'suggesion') then 0
              else 0

(: TODO: This currently also removes part of the Lucene syntax :)
(:
let $query := lib:clear-query($query)
:)

(: This is needed to send the query as XML. If ait's parsable use it otherwise use the text syntax :)
let $xml-query := util:catch('*', util:parse($query), '')
let $query := if (empty($xml-query) or $xml-query = '') then
                $query
              else
                $xml-query
(: TODO: this is a ugly hack and don't work:)
(:
let $defaultSearchElements := if (not(empty($xml-query))) then
                                (<TEI:div/>)
                              else
                                $defaultSearchElements
:)
(:rewrite query for suggestions:)
let $query := if (string-length($query) > 2 and $mode = 'suggestion') then concat($query, '*')
              else $query

let $logQuery := typeswitch ($query)
                    case node() return
                        util:serialize($query,"media-type=text/xml method=xml")
                    default return
                        $query

(: Log the input :)
let $status := util:log('INFO', concat('Document: "', $document, '", Query: "', $logQuery, '", Facet: "', string-join($facets, ','), '", Mode: "', $mode, '"'))

(: calculate the facet base search strings :)
let $facetSearchBasePaths := for $f in $facets
                         return if ($query != '' and $f != '') then
                             concat('$searchSpace//', $f ,'[ft:query(., $query)]/')
                         (: this doesn't work yet since Lucene won't do a search with a single wildcard :)
                         else if ($query = '' and $f != '') then
                             concat('$searchSpace//', $f , '/')
                         else ()

(: Facets: Get search path and log it :)
let $facetSearchPath := archaeo18lib:build-search-path($facetSearchBasePaths, $archeao18conf:searchElements)
let $logFacetSearch := util:log('INFO', concat('Facet search path: ', $facetSearchPath))
(: Normal search: Get search path :)
(: TODO: Make the search elements configurable :)
let $normalSearchBasePaths := for $searchElement in $defaultSearchElements return
                              concat('$searchSpace//', node-name($searchElement)) 
let $normalSearchPath := archaeo18lib:build-search-path($normalSearchBasePaths, '[ft:query(., $query)]')
let $logNormalSearchPath := util:log('INFO', concat('Normal search path: ', $normalSearchPath))

(: execute the query :)
let $results := if (string-length($query) < 2 and $mode = 'suggestion') then ()
                else if ($query != '' and $facet = '') then
                    (:
                    $searchSpace//TEI:p[ft:query(., $query)] | $searchSpace//TEI:head[ft:query(., $query)]
                    :)
                    util:eval($normalSearchPath)
                else if ($query != '' and $facet != '') then
                    util:eval($facetSearchPath)
                else if ($query = '' and $facet != '') then
                    util:eval($facetSearchPath)
                else 
                    ()
(: result paging :)               
let $results := if ($start != 0 or $limit != 0) then
                    subsequence($results, $start, $limit)
                else $results
(:Search is done, time used after this is related to serilisation:)
let $timerEnd := util:system-time()

return <results><query>
         <searchString>{$query}</searchString>
         <hits>{count($results)}</hits>
         <limit>{$limit}</limit>
         <start>{$start}</start>
         <facet>{string-join($facets, ',')}</facet>
         <mode>{$mode}</mode>
         <document>{$document}</document>
         <highlight>{$highlight}</highlight>
         <filter>{$filter}</filter>
         <duration type="search">{$timerStart - $timerEnd}</duration>
         {
         if ($summary != 0) then <summary>{$summary}</summary>
         else ()
         }
       </query>
{
    
    if ($mode = 'statistics' or count($results) < 1) then
        let $hitDocuments := for $r in $results return util:document-name($r)
        for $d in distinct-values($hitDocuments)
        return <document>{archaeo18lib:get-doc-name($d)}</document>
    (: TODO: Add list of given Facets :)
    else if ($query ='' and count($facets) > 0) then
        ()
    
    (: TODO: Try to make this faster :)
    else if ($mode = 'suggestion') then
        if (string-length($query) < 2) then <nosuggestion/>
        else 
            let $suggestions := for $r in $results 
                   (: let $r := util:expand($r) :)
                   (: order by ft:score($r) descending :)
                   return util:expand($r)//exist:match   
            for $s in distinct-values($suggestions)
                   let $c := count($suggestions[.=$s])
                   order by $c descending
                   return <suggestion count="{$c}">{$s}</suggestion>
    (: Handling of modes 'results' and 'xhtml' :)      
    else for $s in $results
        (: TODO: change this to element of search space :)
        let $pageBreak := $searchSpace//*[@id = data($s/@id)]/preceding::TEI:pb[1]
        
        let $pageNr := if (empty($pageBreak)) then
                            0
                       else if ($pageBreak/@n) then
                            data($pageBreak/@n)
                       else
                            count($pageBreak/preceding::TEI:pb)
                            
          (: TODO:
        let $pageNr := $searchSpace//*[@id = data($s/@id)]/preceding::TEI:pb[1]
         
      
                * There is a bug somewere, sometimes there is no page number, sometimes there is more then one
                * Remove this stupid workaround
       
        
        let $pageNr := if (count($pageNr) > 1) then string($pageNr[1]/@n)
                       else if ($pageNr/@n) then string($pageNr/@n)
                       else ''
   :)
        let $result := (: if ($summary != 0) then
                            kwic:summarize($s, <config width="{$summary}"/>)
                       else :) if ($highlight = true()) then 
                            util:expand($s)
                       else $s

        (: filter for enrichment :)
        let $result := if ($filter = true() or $summary != 0) then archaeo18lib:filter-elements($result, <TEI:addName/>, <exist:match/>)
                       else $result

        (: Create summary :)
        (: TODO: Make this work :)
        let $result := if ($summary != 0 and $highlight = true()) then archaeo18lib:shorten($result, local-name(<exist:match/>), 50)
                       else $result

        (: Get the name of the document the hit is in :)
        let $hitDocument := if ($document != '') then $document
                            else archaeo18lib:get-doc-name(util:document-name($s))
                            (:
                            else util:document-name($s)
                            :)
   
        order by ft:score($s) descending
        return 
            <result>
                <doc>{$hitDocument}</doc>
                <page>{$pageNr}</page>
                <score>{ft:score($s)}</score>
                <fragment>{
                if ($mode = 'xhtml') then transform:transform($result, $transform, $params)
                else $result
                }</fragment>
            </result>
        }
       
        <duration type="serializer">{$timerEnd - util:system-time()}</duration>
</results>
