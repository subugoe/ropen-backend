xquery version "1.0";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";

declare namespace TEI="http://www.tei-c.org/ns/1.0";

declare boundary-space preserve;


import module namespace a18enr="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment" at "../modules/archaeo18enrichment.xqm";
import module namespace annotate="http://archaeo18.sub.uni-goettingen.de/exist/annotate" at "../modules/annotate.xqm";
import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "conf.xqm";

declare variable $local:wordIndexFileName := 'wordIndex.xml';
declare variable $local:wordIndexFile := concat($archeao18conf:cacheBase, $local:wordIndexFileName);
declare variable $local:wordIndexContent := doc($local:wordIndexFile);



declare function local:check-words-test($node as node()*) as node()* {
    for $node in $node/node()
    return typeswitch ($node)
        case text () return 
            let $words := annotate:tokenize($node)
            for $i in (1 to count($words))
            (: for $word in $words :)
            let $word := $words[$i]
                
            return 
               $word
        case element () return element {QName (namespace-uri($node), name($node)) }
                                        { $node/@*,
                                            local:check-words($node/node())
                                        }
        default return $node
};

declare function local:check-words($node as node()*) as node()* {
    for $node in $node/node()
    return typeswitch ($node)
        case text () return 
            let $words := annotate:tokenize($node)
            for $i in (1 to count($words))
            (: for $word in $words :)
            let $word := $words[$i]
                
            return 
                let $checkWord := a18enr:normalize-name($word)
                return if (matches($checkWord, '^\w*$') and string-length($checkWord) > 3) then
                    let $entry := local:cache-lookup($checkWord)
                    return if (not(empty($entry)) and count($entry) = 1 and $entry/@wordCount = '1') then
                             element {QName (xs:anyURI('http://www.tei-c.org/ns/1.0'), concat('TEI:', name($entry/@type))) } {
                                 attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:enriched')} {'true'},
                                 attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:created')} {'true'},
                                 attribute ref {$entry/@id},
                                 $word
                             }
                            (:
                            else if (not(empty($entry))) then
                                element {QName (xs:anyURI('http://www.tei-c.org/ns/1.0'), concat('TEI:', name($entry/@type))) } {
                                 attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:enriched')} {'true'},
                                 attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:created')} {'true'},
                                 attribute {QName ('http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment', 'a18enrich:suspicious')} {'true'},
                                 attribute ref {$entry/@id},
                                 $word
                                }
                                :)
                            else
                                $word
                
                else $word
        case element () return element {QName (namespace-uri($node), name($node)) }
                                        { $node/@*,
                                            local:check-words($node/node())
                                        }
        default return $node
};

(:
declare function local:check-suspicious ($nodes as item()*) as item()* {


};
:)

declare function local:cache-lookup ($str as xs:string) as element()* {
    if ($local:wordIndexContent//word[@start = $str]) then
        $local:wordIndexContent//word[@start = $str]
    else ()
};

let $fileName := 'berlin-ne2-spelling-test.xml'
let $document := concat('xmldb:exist:///db/archaeo18/data/tests/', $fileName)




let $text := doc($document)
let $serialization-options := 'method=xml media-type=text/html omit-xml-declaration=no indent=no'
return local:check-words-test($text)
