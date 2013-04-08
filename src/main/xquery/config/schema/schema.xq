xquery version "1.0";

declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";

declare namespace rng="http://relaxng.org/ns/structure/1.0";
declare namespace system="http://exist-db.org/xquery/system";

declare namespace http="http://expath.org/ns/http-client";


declare function local:quote ($str as xs:string) as xs:string {
    let $str := replace($str, '&amp;', '&amp;amp;')
    let $str := replace($str, '&quot;', '&amp;quot;')
    let $str := replace($str, '&apos;', '&amp;apos')
    let $str := replace($str, '<', '&amp;lt;')
    let $str := replace($str, '>', '&amp;gt;')
    return $str
};

declare function local:clean-timestamp ($timestamp as xs:string) as xs:string {
    (:let $timestamp := typeswitch ($timestamp) 
        case xs:dateTime  return xs:string($timestamp)
        default return $timestamp

    return :) replace($timestamp, ':', '-')
};

(:
declare namespace xproc="http://xproc.net/xproc/std"
:)

(: This doesn't do multipart
import module namespace http="http://www.expath.org/mod/http-client" at "resource:org/expath/www/mod/http-client/http-client.xqm";
:)

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../../queries/modules/conf.xqm";

declare option exist:serialize "method=xml media-type=text/xml";

(:
OxGarage is a EGE Webservice, see http://enrich-ege.sourceforge.net/restws.html 
:)
declare variable $local:oxGarage-endpoint := xs:anyURI('http://www.tei-c.org/ege-webservice/Conversions/ODD%3Atext%3Axml/ODDC%3Atext%3Axml/relaxng%3Aapplication%3Axml-relaxng/conversion');

let $mode := util:catch('*', request:get-parameter("mode", 'schema'), 'schema')

(:
Either use "exist" or "expath" 
:)
let $http-module := 'exist'
let $oddFile := doc('./Archaeo18.xml')
let $cacheFile := 'Archaeo18.rng'

(:
let $properties := <conversions><conversion index="0"></conversion><conversion index="1"><property id="oxgarage.getImages">false</property><property id="oxgarage.getOnlineImages">false</property><property id="oxgarage.lang">en</property><property id="oxgarage.textOnly">true</property><property id="pl.psnc.dl.ege.tei.profileNames">default</property></conversion></conversions>
:)
(: This is need only to safe a new version :)
let $login := xmldb:login($archeao18conf:dataBase, $archeao18conf:user, $archeao18conf:password)


(: get last modified date :)
let $lastModifiedDate := xmldb:last-modified(util:collection-name($oddFile), util:document-name($oddFile))
let $cacheFileName := concat($archeao18conf:schemaCacheBase, $cacheFile, '.', $mode, '.', local:clean-timestamp(xs:string($lastModifiedDate)), '.xml')
let $cacheFileExists := not(empty(doc($cacheFileName)))
let $status := util:log('INFO', concat('LastModDate: "', $lastModifiedDate, '", looking for: "', $cacheFileName, '" Exists?: "', $cacheFileExists, '"'))

let $schemaURI := concat('xmldb:exist://', util:collection-name($oddFile), '/', util:document-name($oddFile))
(: Check if the Schema is already on the Server, if not call OxGarage :)
let $schema :=  if ($cacheFileExists) then 
                    doc($cacheFileName)
                else if ($mode = 'schema') then
                    (:
                    this could be determinated at runtime:
                    (starts-with(system:get-version(), '1.5') or starts-with(system:get-version(), '2'))
                    :)
                    let $rawSchema := if ($http-module = 'exist') then
                    
                        (:This doesn't work in eXist 1.4.1 and probably earlier :)
                        
                        let $status := util:log('INFO', concat('Calling OxGarage (', $local:oxGarage-endpoint, ') for ', $schemaURI))
                    
                        let $requestContent := <httpclient:fields>
                                                    <httpclient:field name="upload" value="{$schemaURI}" type="file"/>
                                               </httpclient:fields>
                        let $result := util:eval('httpclient:post-form($local:oxGarage-endpoint, $requestContent, false(), ())')                 
                        let $status := util:log('INFO', concat('Result: ', $result))
                        return $result
                    else if ($http-module = 'expath') then
                    
                        let $request := <http:request href="{$local:oxGarage-endpoint}" method="post" override-media-type="application/xml">
                                            <http:multipart media-type="multipart/form-data" boundary="{$lastModifiedDate}">
                                                <http:header name="Content-Disposition" value='form-data; name="upload"; filename="{util:document-name($oddFile)}"'/>
                                                <http:body media-type="application/xml">
                                                    {util:serialize($oddFile,'method=xml omit-xml-declaration=yes"')}
                                                (:
                                                    <![CDATA[{util:serialize($oddFile,'method=text omit-xml-declaration=ye"')}]]>
                                                    :)
                                                </http:body>
                                            </http:multipart>
                                         </http:request>
                        let $status := util:log('INFO', concat('Calling OxGarage (', $local:oxGarage-endpoint, ') for ', $schemaURI))
                        let $result := util:eval('http:send-request($request)')
                        let $status := util:log('INFO', concat('Result: ', $result))
                        return $result
                     else ()
                     
                     return util:parse($rawSchema)//rng:grammar
                        
                        (:
                        httpclient:post(xs:anyURI($oxGarageEndpoint), doc($oddFile), false(), ())//rng:grammar
                        :)
                else
                    ()
let $status := util:log('INFO', $schema)
(: Safe the Schema if it not already is :)
(:
let $store := if (not($cacheFileExists)) then 
                xmldb:store(util:collection-name($cacheFileName), util:document-name($cacheFileName), $schema)
              else
                ()
:)
return $schema