xquery version "1.0";

declare namespace util="http://exist-db.org/xquery/util";

module namespace eXist-ext="http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/eXist-extensions";

declare function eXist-ext:introspect ($func as xs:QName) as node(){
    let $doc := util:describe-function($func)
    let $sig := $doc//signature
    let $return := substring-after($sig, ') ')
    let $args := substring-before(substring-after($sig, '('), ') ')
    return <function name="{$doc/@name}" module="{$doc/@module}">
        <prototype arguments="{$doc//prototype/@arguments}">
        {$doc//signature}
        <eXist-ext:signature>
            <eXist-ext:name>{$doc/@name}</eXist-ext:name>
            <eXist-ext:args>{
            for $arg in tokenize($args, ',')
                let $arg := replace($arg, '^\s+', '')
                return if (not(contains($arg, '...'))) then
                    <eXist-ext:arg name="{tokenize($arg, ' as ')[1]}" type="{tokenize($arg, ' as ')[2]}"/>   
                else 
                    <eXist-ext:vargs/>  
            }</eXist-ext:args>
            <eXist-ext:returnType>{$return}</eXist-ext:returnType>
        </eXist-ext:signature>
        {$doc//description}
        </prototype>
        </function>
}; 

declare function eXist-ext:check-get-fragment-between-namespace () as xs:boolean {
    let $num-of-args := util:describe-function(QName('http://exist-db.org/xquery/util', 'util:get-fragment-between'))//prototype/@arguments
    return if ($num-of-args > 3 or $num-of-args = -1) then
        true()
    else
        false()
 };