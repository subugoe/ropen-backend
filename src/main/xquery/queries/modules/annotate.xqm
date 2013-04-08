xquery version "1.0";

module namespace annotate="http://archaeo18.sub.uni-goettingen.de/exist/annotate";

declare namespace util="http://exist-db.org/xquery/util";

import module namespace lib="http://sub.uni-goettingen.de/exist/lib" at "lib.xqm";

declare option exist:serialize "indent=no";

declare variable $annotate:word-pattern := '^\w+$';

declare function annotate:sequence-to-string ($seq as item()*) as xs:string {
    let $strs := for $s in $seq
                 return string($s)
    return string-join($strs, '')
};


declare function annotate:tokenize ($str as xs:string) as xs:string* {
    let $token := replace($str, '^(\w+|\W+)(.*)$', '$1')
    let $remainder := substring($str, string-length($token) + 1, string-length($str))
    return if (string-length($remainder) = 0) then $str
           else ($token, annotate:tokenize($remainder))
};

declare function annotate:extract-annotation ($annotation as element(), $search as xs:string, $content as item()*) as item()* {
    if (count($annotation/node()) = 1 and $annotation/node() instance of element()) then
        element {QName (namespace-uri($annotation), name($annotation)) }
            { $annotation/@*,
                annotate:extract-annotation($annotation/node(), $search, $content)
            }
    else if ($annotation/node() instance of text() and string($annotation/node()) = $search)  then
        element {QName (namespace-uri($annotation), name($annotation)) }
            { $annotation/@*,
                $content
            }
    else ()
};

declare function annotate:annotate-with-hint ($hint as xs:string, $content as item()*, $annotate-function as function) as element() {
    let $annotatedHint := annotate:annotate-strings($hint, $annotate-function)
    return annotate:extract-annotation($annotatedHint, $hint, $content)
};

declare function annotate:annotate-words ($strs as xs:string*, $annotate-function as function) as item()* {
    annotate:annotate-strings-with-pattern($strs, $annotate:word-pattern, $annotate-function)
};

declare function annotate:annotate-strings-with-pattern ($strs as xs:string*, $pattern as xs:string, $annotate-function as function) as item()* {
    for $str in $strs
    return if (matches($str, $pattern)) then annotate:annotate-strings($str, $annotate-function)
           else $str
};

declare function annotate:annotate-strings ($strs as xs:string*, $annotate-function as function) as node()* {
    for $str in $strs
    return util:call($annotate-function, $str)
};

declare function annotate:annotate-words-with-filter ($nodes as node()*, $annotate-function as function) as item()* {
    annotate:annotate-words-with-filter($nodes, (), (), $annotate-function)
};

declare function annotate:annotate-words-with-filter ($nodes as node()*, $inline as element()*, $ignore as element()*, $annotate-function as function) as item()* {
    for $i in (1 to count($nodes))
    return typeswitch($nodes[$i])
                case text() return
                    let $tokens := annotate:tokenize (string($nodes[$i]))
                    (: Check if text node ends with character or line wrap :)
                     
                    let $resultTokensEnd := if ($i != count($nodes) and lib:element-in-list($nodes[($i + 1)], $inline) and matches($tokens[last()], '(-\s*|\w)$')) then
                                                if (matches($tokens[last()], '-\s*$')) then
                                                    subsequence($tokens, 1, count($tokens) - 2)
                                                else
                                                    subsequence($tokens, 1, count($tokens) - 1)
                                            else ()
                     let $resultTokensStart := if (not(empty($resultTokensEnd)) and ($i != count($nodes) and lib:element-in-list($nodes[($i - 1)], $inline) and matches($resultTokensEnd[1], '^\w'))) then               
                                            subsequence($resultTokensEnd, 2, count($resultTokensEnd))
                                        else if ($i != count($nodes) and lib:element-in-list($nodes[($i + 1)], $inline) and matches($tokens[1], '^\w')) then
                                            subsequence($tokens, 2, count($tokens))
                                        else if (not(empty($resultTokensEnd))) then
                                            $resultTokensEnd
                                        else
                                            ()
                     let $text := if (not(empty($resultTokensStart)) and count($tokens) != count($resultTokensStart)) then
                                        string-join($resultTokensStart, '')
                                  else $nodes[$i]
                    
                   
                    return annotate:annotate-words(annotate:tokenize(string($text)), $annotate-function)
                
                case element() return
                    let $content := if (lib:element-in-list($nodes[$i], $inline)) then
                                        let $tokensNext := if ($nodes[($i + 1)] instance of text()) then
                                                                annotate:tokenize (string($nodes[($i + 1)]))
                                                            else
                                                                ()
                                        let $tokensPrevious := if ($nodes[($i - 1)] instance of text()) then
                                                                annotate:tokenize (string($nodes[($i - 1)]))
                                                            else
                                                                ()
                                        (: This handles elements plus the suspected text node constructing a word :)
                                        (: If the last token of the previous string is '-\s*$' also include the second to last:)
                                        let $lastOfPrevious := if (matches($tokensPrevious[last()], '-\s*$')) then
                                                                    ($tokensPrevious[count($tokensPrevious) - 1], $tokensPrevious[last()])
                                                               else
                                                                    $tokensPrevious[last()]
                                        
                                        return if (matches($tokensPrevious[last()], '(-\s*|\w)$') and matches($tokensNext[1], '^\w')) then
                                            ($lastOfPrevious, $nodes[$i], $tokensNext[1])
                                        else if (matches($tokensPrevious[last()], '(-\s*|\w)$')) then
                                            ($lastOfPrevious, $nodes[$i])
                                        else if (matches($tokensNext[1], '^\w')) then
                                            ($nodes[$i], $tokensNext[1])
                                        
                                        else $nodes[$i]
                                     else ()
                        
                    return if (count($content) > 1) then
                               annotate:annotate-with-hint(annotate:sequence-to-string($content[matches(., $annotate:word-pattern)]), $content, $annotate-function)
                           else if (count($content) = 1) then
                               $content
                           else
                               (: Just copy any other element :)
                               element {QName (namespace-uri($nodes[$i]), name($nodes[$i])) }
                                   { $nodes[$i]/@*,
                                       annotate:annotate-words-with-filter($nodes[$i]/node(), $inline, $ignore, $annotate-function)
                                   }
                default return $nodes[$i]
    
  
        

(: This works on element level but ignores inlined elements :)
(:
    for $node in $nodes
            return 
            typeswitch($node)
                case text() return annotate:annotate-words(annotate:tokenize (string($node)))
                case element() return if (lib:element-in-list($node, $inline)) then 
                                        annotate:annotate-with-hint(string($node), $node)
                                  else if (lib:element-in-list($node, $ignore)) then 
                                        $node
                                  (:
                                  Add Check for inlining here
                                  :)
                                  else 
                                        element {QName (namespace-uri($node), name($node)) }
                                            { $node/@*,
                                                annotate:annotate-words-with-filter($node/node(), $inline, $ignore)
                                            }
                default return $node
:)
};


declare function annotate:annotate-word-boundaries ($words as xs:string*) as item()* {
    for $word in $words
    return <word checkedWord="{$word}">{$word}</word>
};


