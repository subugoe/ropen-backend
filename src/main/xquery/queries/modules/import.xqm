xquery version "1.0";

module namespace ingest="http://archaeo18.sub.uni-goettingen.de/exist/import";

declare namespace TEI="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace METS="http://www.loc.gov/METS/";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "conf.xqm";

declare variable  $ingest:enrichStylesheet := $archeao18conf:stylesheetImportEnrichStylesheet;
declare variable  $ingest:enrichMetadataStylesheet := $archeao18conf:stylesheetImportEnrichMetadataStylesheet;
declare variable  $ingest:metsStylesheet := $archeao18conf:stylesheetImportMetsStylesheet;

declare option exist:serialize "method=xml media-type=text/xml";

(: TODO: 
        * finish documentation
        * try to get rid of configuration variables, everything should be a parameter
        * remove variabels from the ingest namespace
        * check if false is returned somewere
:)

(:~
: Enriches the TEI with pagenumbers ans identifiers
: @param a node containing the TEI
: @return a node containing the result
:)

declare function ingest:enrichTEI ($content as node()) as node() {
    ingest:transform($content, $archeao18conf:stylesheetImportEnrichStylesheet)
};

(:~
: Creates a METS file as node list
: @param a node containing the TEI
: @return a node containing the METS result
:)

declare function ingest:createMets ($content as node(), $identifier as xs:string) as node() {
    let $params := 
        <parameters>
            <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
            <param name="identifier" value="{$identifier}"/>
        </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetImportMetsStylesheet))
    return transform:transform($content, $transform, $params)
};

(:~
: Enriches the TEI with metadata like spelling variants
: @param a node containing the TEI
: @return a node containing the result
:)

declare function ingest:enrichTEIMetadata ($content as node()) as node() {
    (:
    let $params := 
        <parameters>
        </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, $archeao18conf:stylesheetImportEnrichMetadataStylesheet))
    return transform:transform($content, $transform, $params)
    :)
    ingest:transform($content, $archeao18conf:stylesheetImportEnrichMetadataStylesheet)
};

(:~
: Enriches the TEI using the give stylesheet (internal function)
: @param a node containing the TEI
: @param a node containing the transformation
: @return a node containing the result
:)

declare function ingest:transform ($content as node(), $stylesheet as xs:string) as node() {
     let $params := 
        <parameters>
            <param name="baseuri" value="{$archeao18conf:transformationRestBase}"/>
        </parameters>
    let $transform := doc(concat($archeao18conf:transformationsBase, $stylesheet))
    return transform:transform($content, $transform, $params)
};

declare function ingest:importMETS($file as xs:string, $identifier as xs:string, $metsCollection as xs:string) as xs:boolean {
    let $metsDoc := ingest:createMets(doc($file), $identifier)
    let $metsStore := xmldb:store($metsCollection , concat($identifier, $archeao18conf:metsSuffix), $metsDoc)
    return true()    
};

(:TODO: Check if this throws an exception :)
declare function ingest:downloadMETS($url as xs:string, $identifier as xs:string, $metsCollection as xs:string) as xs:boolean {
    let $metsURL := if ($url castable as xs:anyURI)
                    then xs:anyURI($url)
                    else false()
    let $metsDoc := httpclient:get($metsURL, false(), ())//METS:mets
    let $metsStore := xmldb:store($metsCollection , concat($identifier, $archeao18conf:metsSuffix), $metsDoc)
    return true()
};

declare function ingest:importTEI($file as xs:string, $identifier as xs:string, $enrichedTeiCollection as xs:string) as xs:boolean  {
    let $enrichedDoc := ingest:enrichTEIMetadata(ingest:enrichTEI(doc($file)))
    let $teiStore := xmldb:store($enrichedTeiCollection , concat($identifier, $archeao18conf:teiEnrichedSuffix), $enrichedDoc)
    return true()
};