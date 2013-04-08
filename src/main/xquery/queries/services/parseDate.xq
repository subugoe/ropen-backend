xquery version "1.0";

import module namespace date = "http://archaeo18.sub.uni-goettingen.de/exist/date" at "../modules/date.xqm";

let $date := util:catch('*', request:get-parameter("date", ''), '')
return date:date-entry ($date, ())