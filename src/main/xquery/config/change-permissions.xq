xquery version "1.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";

import module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../queries/modules/conf.xqm";

declare variable $local:mode := util:base-to-integer(0755, 8);
declare variable $local:change-permisions := true();

let $login := xmldb:login($archeao18conf:base, $archeao18conf:user, $archeao18conf:password)

let $changed := xmldb:chmod-collection($archeao18conf:base, $local:mode)

return <changed>{$changed}</changed>