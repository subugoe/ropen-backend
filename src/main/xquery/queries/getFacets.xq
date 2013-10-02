xquery version "1.0";

declare namespace request="http://exist-db.org/xquery/request";

declare option exist:serialize "method=xml media-type=application/xml";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";
(:
$archeao18conf:entities
:)
let $header := response:set-header( "Cache-Control", 'public,max-age=2592000,s-maxage=2592000')


return doc(concat($archeao18conf:configBase, $archeao18conf:facets-xml))
