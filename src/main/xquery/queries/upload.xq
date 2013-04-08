xquery version "1.0";

declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace METS="http://www.loc.gov/METS/";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "modules/conf.xqm";
import module namespace ingest = "http://archaeo18.sub.uni-goettingen.de/exist/import" at "modules/import.xqm";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

(: TODO:
        * Add documentation
        * show a message if upload is disabled - done 
        * check if false is returned somewere -done
        * Merge the frontend in here - done
        * remove duplicate variables - dome
        * check if it still works
        * add fields for a coustom document id
:)
 
declare function local:import ($fileName as xs:string, $fileContent as xs:base64Binary, $metsUrl as xs:string ) as xs:boolean {
    let $documentName := replace($fileName, '.xml', '')
    let $store := xmldb:store(concat($archeao18conf:dataBase, $archeao18conf:teiPrefix), $fileName, $fileContent)
    let $origTei := concat($archeao18conf:dataBase, $archeao18conf:teiPrefix, $fileName)
    let $teiStore := ingest:importTEI($origTei, $documentName, concat($archeao18conf:dataBase, $archeao18conf:teiEnrichedPrefix))

    let $generateMETS := if (not($metsUrl)) then
                            ingest:importMETS($origTei, $documentName, concat($archeao18conf:dataBase, $archeao18conf:metsPrefix))
                         else 
                            ingest:downloadMETS($metsUrl, $documentName, concat($archeao18conf:dataBase, $archeao18conf:metsPrefix))
    return if ($store and $generateMETS and $teiStore) then
                true()
           else
                false()
};

(: TODO: finish this
let $metsFilename := request:get-uploaded-file-name('metsfile')
let $documentName := request:get-parameter("identifier",0)
:)

<xhtml:html>
    <xhtml:head>
        <xhtml:title>Archeao18 Upload</xhtml:title>
    </xhtml:head>
    <xhtml:body>{
let $fileName := request:get-uploaded-file-name('file')
let $fileContent := request:get-uploaded-file-data('file')
let $metsURL := util:catch('*', request:get-parameter("metsurl", false()), false())

let $upload := if (not(empty($fileContent))) then
                    true()
               else
                    false()

(: Check if upload is en abled and log in if it is :)
let $login := if ($archeao18conf:functionUpload and $upload) then
                xmldb:login($archeao18conf:dataBase, $archeao18conf:user, $archeao18conf:password)
              else
                false()

let $uploadSucceded := if ($upload)  then
                            local:import ($fileName, $fileContent, $metsURL)
                       else 
                            false()
(: Log Status :)
let $status := util:log('INFO', concat('Upload: File: "', $fileName, '", METS URL: "', $metsURL, '"'))

return if (not($archeao18conf:functionUpload)) then
            <p>The Upload is disabled by configuration</p>
       else if ($upload and $uploadSucceded) then
            <p>File {$fileName} has been imported.</p>
       else if ($upload and not($uploadSucceded)) then
            <p>Error: File {$fileName} hasn't been imported!</p>            
       else 
            let $uploadPath := if ($archeao18conf:httpIsRequest) then 
                                    $archeao18conf:httpRestCallPath
                               else
                                    '/exist/rest/db/archaeo18/queries/upload.xq'
            return
            <form enctype="multipart/form-data" method="post" action="{$uploadPath}">
                <fieldset>
                    <legend>Upload Document:</legend>
                    <input type="file" name="file"/>
                    <!-- <legend>Upload METS file (optional):</legend><input type="file"
                        name="metsfile" /> -->
                    <legend>METS file URL (optional):</legend>
                    <input type="text" name="metsurl"/>
                    <br/>
                    <!-- <input type="text" name="identifier"/> -->
                    <input type="submit" value="Upload"/>
                </fieldset>
            </form>
}
 </xhtml:body>
</xhtml:html>