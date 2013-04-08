xquery version "1.0";

module namespace a18enr="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment";

declare namespace TEI="http://www.tei-c.org/ns/1.0";

import module namespace date="http://archaeo18.sub.uni-goettingen.de/exist/date" at "date.xqm";
import module namespace annotate="http://archaeo18.sub.uni-goettingen.de/exist/annotate" at "annotate.xqm";
import module namespace spelling="http://archaeo18.sub.uni-goettingen.de/exist/spelling" at "spelling.xqm";
import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "conf.xqm";
import module namespace strings = "http://archaeo18.sub.uni-goettingen.de/exist/strings" at "strings.xqm";

declare variable $a18enr:tei-namespace := xs:anyURI('http://www.tei-c.org/ns/1.0');

declare variable $a18enr:inline := (<TEI:lb/>, <TEI:expan/>, <TEI:ins/>, <TEI:add/>);
declare variable $a18enr:ignore := (<TEI:del/>, <TEI:sic/>);

(: Cache stuff :)
declare variable $a18enr:cacheFileName := 'entityCache.xml';
declare variable $a18enr:cacheFile := concat($archeao18conf:cacheBase, $a18enr:cacheFileName);
declare variable $a18enr:cache := doc($a18enr:cacheFile);

declare function a18enr:normalize-name ($args as xs:string*) as xs:string* {
    for $arg in $args
        let $clean := replace(replace($arg, '\W', ' '), '\s+', ' ')
        let $lc := lower-case($clean)
    return $lc
};

declare function a18enr:add-spelling-variants($words as xs:string*) as item()* {
    for $word in $words
        for $w in tokenize($word, '\W+')
        return if ($w[. != '']) then
                    let $w := spelling:generate-modern-variant($w)
                    let $variants := spelling:check-word($w)
                    return if (not($variants/suggestion)) then 
                        $w
                    else
                        <TEI:name>{$w}<TEI:addName>{$variants//suggestion[1]/text()}</TEI:addName></TEI:name>
               else $w
};

declare function a18enr:annotate-date ($e as element()) as element() {
    if (not($e[@when] or $e[@when = ''])) then
        let $date := date:parse-date(string($e))
        return if ($date != '') then
                    element {QName (namespace-uri($e), name($e)) }
                        { $e/@*,
                            attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:enriched')} {'true'},
                            attribute when {$date}, 
                            $e/node()
                        }
                else $e
    else $e
};

declare function a18enr:annotate-bibl ($e as element()) as element() {
    if (not($e[@target]) or $e[@target = '']) then
        let $type := local-name($e)
        let $id := $a18enr:cache//entry[@type = $type]/name[.=string($e)]/../@id
        return if ($id != '') then
                    element {QName (namespace-uri($e), name($e)) }
                        { $e/@*,
                            attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:enriched')} {'true'},
                            attribute ref {$id}, 
                            $e/node()
                        }
                else $e
    else $e
};

declare function a18enr:annotate-ref ($e as element()) as element() {
    if (not($e[@ref]) or $e[@ref = '']) then
        let $type := local-name($e)
        let $id := $a18enr:cache//entry[@type = $type]/name[. = string($e)]/../@id
        let $id := if ($id = '' and matches(string($e), '[,.;:-]')) then
                        $a18enr:cache//entry[@type = $type]/*[. = string($e)]/../@id
                   else
                        $id
        return if ($id != '') then
                    element {QName (namespace-uri($e), name($e)) }
                        { $e/@*,
                            attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:enriched')} {'true'},
                            attribute ref {$id}, 
                            $e/node()
                        }
                else $e
    else $e
};

declare function a18enr:annotate-elements ($items as item()*) as item()* {
    for $item in $items
    return typeswitch ($item)
        case element (TEI:date) return a18enr:annotate-date($item)
        case element (TEI:persName) return a18enr:annotate-ref($item)
        case element (TEI:placeName) return a18enr:annotate-ref($item)
        case element (TEI:term) return a18enr:annotate-ref($item)
        (: Deactivated - 30.5.12 :)
        (:
        case element (TEI:ref) return if ($item/parent::TEI:bibl) then
                                            a18enr:annotate-bibl($item)
                                      else
                                            $item
        :)
        case element () return element {QName (namespace-uri($item), name($item)) }
                                        { $item/@*,
                                            a18enr:annotate-elements($item/node())
                                        }
        case document-node () return document {
                                                a18enr:annotate-elements($item/node())
                                              }
        
        default return $item

};



declare function annotate:annotate-words ($words as xs:string*) as item()* {
    for $word in $words
    return <word checkedWord="{$word}">{$word}</word>
};
(:
declare function a18enr:resolve-identifiers ($ids as xs:string) as xs:string* {
    (: Split multiple IDs in one String :)
    let $ids := for $id in tokenize($ids, '\s*?#')
                return if ($id != '') then
                    $id
                else
                    ()
    
    let $prefixes := <prefixes>
                        <!--
                        <prefix name="dnb" uri="http://d-nb.info/gnd/" pattern=""/>
                        -->
                        <prefix name="getty" uri="http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=" pattern="#GettyID:(\d{7,8})"/>
                        <prefix name="cerl" uri="http://thesaurus.cerl.org/cgi-bin/record.pl?rid=" pattern="#CerlID:(cn[pi]\d{8,9})"/>
                        <prefix name="census" uri="http://census.bbaw.de/easydb/censusID=" start="#CensusID:(\d{9})"/>
                        <!--
                        <prefix name="" uri="" pattern=""/>
                        -->
                     </prefixes>
    

    for $id in $ids
    return if (starts-with($id, '#http')) then
                replace($id, '#', '')
    
           else 
                for $prefix in $prefixes//prefix
                    return if () then
                            
                            else
                                ()

};
:)
declare function a18enr:annotate-entity ($str as xs:string) as node() {
    let $len := string-length($str)
    let $wordCount := strings:word-count($str)
    
    

    (:first a normal lookup:)
    let $entries := $a18enr:cache//entry[child::name[.=string($str)]]
        
    
    
    let $hit := if (count($entries) = 1) then
                    $entries
                else if (count($entries) > 1) then
                    (:if there are multiple hits, try to check occurenes:)
                    (: order by occurence :)
                    (:
                    for $entry in $entries
                    order by sum($entry//name/@occurences) descending
                    return $entry
                    :)
                    ()
                else
                    ()
    
    
    (:if there is no hit use variants:)
    
    (:then check normilized forms :)
    
    let $element := if (count($hit) = 1) then
                        ()
                        (:
                        let $type := $hit/@type
                        element {QName (namespace-uri($a18enr:tei-namespace), name($type)) } {}
        :)
        
                    else
                        ()
    
    return ()
};

(:
declare variable $a18enr:add-spelling-variants-function := util:function(QName('http://archaeo18.sub.uni-goettingen.de/exist/enrichment',"a18enr:add-spelling-variants"), 1)
let $annotate-word-boundaries-function := util:function(QName(' http://www.w3.org/2005/xquery-local-functions',"local:annotate-word-boundaries"), 1)




return local:annotate-words-with-filter($str, $inline, $ignore, $annotate-word-boundaries-function)
:)