xquery version "1.0";

module namespace strings="http://archaeo18.sub.uni-goettingen.de/exist/strings";

declare function strings:match-sequence-any ($input as xs:string, $patterns as xs:string*) as xs:boolean {
    let $matches := for $p in $patterns return
                        matches($input, $p)
    return if ($matches = true()) then true()
           else false()
};

declare function strings:replace-sequence ($input as xs:string, $patterns as xs:string*) as xs:string? {
    if (count($patterns) > 0) then strings:replace-sequence(replace($input, $patterns[1], ''), $patterns[fn:position() > 1])
    else $input
};

declare function strings:find-first-match ($input as xs:string, $patterns as element()) as xs:string {
    let $results := for $p in $patterns//*/@pattern return
                        if (matches($input, $p)) then $patterns//*[@pattern = $p]/@match
                        else ''
    return if (not(empty(distinct-values($results[not(. = '')])))) then
                distinct-values($results[not(. = '')])[1]
           else ''
};

declare function strings:find-match ($input as xs:string, $patterns as element()) as xs:string* {
    let $results := for $p in $patterns//*/@pattern return
                        if (matches($input, $p)) then $patterns//*[@pattern = $p]/@match
                        else ''
    return distinct-values($results[not(. = '')])
};

declare function strings:word-count ($arg as xs:string?) as xs:integer {
   count(tokenize($arg, '\W+')[. != ''])
};

declare function strings:trim ( $arg as xs:string? )  as xs:string {
    replace(replace($arg,'\s+$',''),'^\s+','')
};
