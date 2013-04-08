xquery version "1.0";

module namespace spelling="http://archaeo18.sub.uni-goettingen.de/exist/spelling";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";

declare variable $spelling:spellcheckEndpoint := xs:anyURI('https://www.google.com/tbproxy/spell?lang=de&amp;hl.de');
declare variable $spelling:checker := <google/>;

(: see http://www.gmacker.com/web/content/tutorial/googlespellchecker/googlespellchecker.htm :)

declare function spelling:generate-modern-variant($words as xs:string*) as xs:string* {
    for $word in $words
    let $word := replace($word, 'ß', 'ss')
    (:Add more transformations here :)
    return $word
};

declare function spelling:check-word($word as xs:string*) as element()* {
    typeswitch ($spelling:checker)
        case element(google) return spelling:check-word-google($word)
        default return $word
};

declare function spelling:check-word-google($words as xs:string*) as element()* {
    for $word in $words
    let $request := <spellrequest textalreadyclipped="0" ignoredups="1" ignoredigits="1" ignoreallcaps="0">
                        <text>{$word}</text>
                    </spellrequest>
    let $response := httpclient:post($local:spellcheckEndpoint, $request, true(), ())//spellresult
    return <word w="{$word}">{
        if (not($response/c)) then ()
           else for $suggestion in tokenize($response/c, '\W+')
                return <suggestion>{$suggestion}</suggestion>
           }</word>
};

