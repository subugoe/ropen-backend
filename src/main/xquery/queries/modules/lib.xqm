xquery version "1.0";

module namespace lib="http://sub.uni-goettingen.de/exist/lib";

(: TODO:
        * add documentation
:)

declare function lib:milestone-chunk-ns(
  $ms1 as element(),
  $ms2 as element(),
  $node as node()*
) as node()*
{
  typeswitch ($node)
    case element() return
      if ($node is $ms1) then $node
      else if ( some $n in $node/descendant::* satisfies ($n is $ms1 or $n is $ms2) )
      then
        (: element { name($node) } :)
           element {QName (namespace-uri($node), name($node))}
                { for $i in ( $node/node() | $node/@* )
                  return lib:milestone-chunk-ns($ms1, $ms2, $i) }
      else if ( $node >> $ms1 and $node << $ms2 ) then $node
      else ()
    case attribute() return $node (: will never match attributes outside non-returned elements :)
    default return 
      if ( $node >> $ms1 and $node << $ms2 ) then $node
      else ()
};

(:
See http://en.wikibooks.org/wiki/XQuery/Keyword_Search#Filter_Search_Parameters
:)
declare function lib:clear-query($query as xs:string) as xs:string {
    $query
    (: TODO: This also removes the Lucene search syntax :)
    (:
    replace($query, "[&amp;&quot;-*;-`~!@#$%^*()_+-=\[\]\{\}\|';:/.,?:]", "")
    :)
};

declare function lib:element-in-list ($elem as element(), $list as element()*) as xs:boolean {
    if (empty($list)) then
        false()
    else if ($list/self::*[local-name() = local-name($elem)]) then 
        true()
    else
        false()
};