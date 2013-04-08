xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace system="http://exist-db.org/xquery/system";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace TEI="http://www.tei-c.org/ns/1.0";

import module namespace archeao18conf = "http://archaeo18.sub.uni-goettingen.de/exist/conf" at "../modules/conf.xqm";
import module namespace a18enr = "http://sub.uni-goettingen.de/DB/ENT/projects/archaeo18/enrichment" at "../modules/archaeo18enrichment.xqm";

let $fileContent := request:get-uploaded-file-data('file')

let $upload := if (not(empty($fileContent))) then
                    true()
               else
                    false()

return if (not($upload)) then 
    let $serialization-options := 'method=xhtml media-type=text/html indent=yes'
    return <xhtml:html>
    <xhtml:head>
        <xhtml:title>Archeao18 Annotator</xhtml:title>
    </xhtml:head>
    <xhtml:body>{

        if (not($archeao18conf:functionUpload)) then
            <p>The Upload is disabled by configuration</p>

        else 
            let $uploadPath := if ($archeao18conf:httpIsRequest) then 
                                    $archeao18conf:httpRestCallPath
                               else
                                    '/exist/rest/db/archaeo18/queries/experimental/neEnrichment.xq'
            return
            <xhtml:form enctype="multipart/form-data" method="post" action="{$uploadPath}">
                <xhtml:fieldset>
                    <xhtml:legend>Upload Document:</xhtml:legend>
                    <xhtml:input type="file" name="file"/>
                    <xhtml:br/>
                    <!-- <input type="text" name="identifier"/> -->
                    <xhtml:input type="submit" value="Start enrichment"/>
                </xhtml:fieldset>
            </xhtml:form>
}
 </xhtml:body>
</xhtml:html>
else 
    let $doc-string := if (starts-with(system:get-version(), '1.4')) then
                            util:binary-to-string($fileContent)
                       else if (starts-with(system:get-version(), '1.5') or starts-with(system:get-version(), '2')) then
                            util:base64-decode(xs:string($fileContent))
                       else 
                            ()
    let $annotatedDoc := if ($upload) then
                            a18enr:annotate-elements(util:parse($doc-string))
                       else 
                            false()
    let $serialization-options := 'method=xml media-type=text/html omit-xml-declaration=no indent=no'
    return $annotatedDoc