xquery version "1.0";

module namespace archeao18conf="http://archaeo18.sub.uni-goettingen.de/exist/conf";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace request="http://exist-db.org/xquery/request";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Basic variables :)
declare variable $archeao18conf:base := '/db/archaeo18/';
(: This is needed for writing (upload) and reindexing, disable both if these are empty :)
declare variable $archeao18conf:user := '';
declare variable $archeao18conf:password := '';

(: Functionality :)
declare variable $archeao18conf:functionReindex := true();
declare variable $archeao18conf:functionUpload := true();
declare variable $archeao18conf:functionDocumentation := true();

(: Paths and file parts :)
declare variable $archeao18conf:restBase := '/exist/rest';
declare variable $archeao18conf:dataPrefix := 'data/';
declare variable $archeao18conf:teiPrefix := 'tei/';
declare variable $archeao18conf:metsPrefix := 'mets/';
declare variable $archeao18conf:cachePrefix := 'cache/';
declare variable $archeao18conf:configPrefix := 'config/';
declare variable $archeao18conf:schemaPrefix := 'schema/';
declare variable $archeao18conf:metsSuffix := '.mets.xml';
declare variable $archeao18conf:transformationsPrefix := 'transformations/';
declare variable $archeao18conf:queriesPrefix := 'queries/';
declare variable $archeao18conf:teiEnrichedPrefix := 'tei-enriched/';
declare variable $archeao18conf:teiEnrichedSuffix := "-enriched.xml";

(: search related configuration :)
(: Defines findable document fragments, update indexer configuration if you change this. :)
declare variable $archeao18conf:searchElements := ('parent::TEI:p', 'parent::TEI:head');
declare variable $archeao18conf:searchFacetSeperator := '[,;]';
(: Don't set this to low, identical term are grouped for sorting :)
declare variable $archeao18conf:searchSuggesionLimit := 10;
(: Default operation mode for search :)
declare variable $archeao18conf:searchDefaultMode := 'result';
(: "Width" of summaries:)
declare variable $archeao18conf:searchSummaryWidth := 200;

(: Entities :)
declare variable  $archeao18conf:entities :=  <tei:tei>
        <tei:persName rend="true"><foreign xml:lang="de">Person</foreign>
        <foreign xml:lang="en">person</foreign>
        </tei:persName>
        <tei:placeName rend="true">
        <foreign xml:lang="de">Ortsname</foreign>
        <foreign xml:lang="en">place</foreign>
        </tei:placeName>
        <tei:bibl rend="true">
        <foreign xml:lang="de">Literatur</foreign>
        <foreign xml:lang="en">literature</foreign>
        </tei:bibl>
        <tei:term rend="true"><foreign xml:lang="de">Werk</foreign>
        <foreign xml:lang="en">work</foreign></tei:term>
        <tei:date><foreign xml:lang="de">Datum</foreign>
        <foreign xml:lang="en">date</foreign></tei:date>
        <tei:head><foreign xml:lang="de">Überschrift</foreign>
        <foreign xml:lang="en">heading</foreign></tei:head>
        <tei:teiHeader>
        <foreign xml:lang="de">Metadaten</foreign>
        <foreign xml:lang="en">metadata</foreign>
        </tei:teiHeader>
        <tei:note>
        <foreign xml:lang="de">Anmerkungen</foreign>
        <foreign xml:lang="en">notes</foreign>
        </tei:note>
        <tei:hi>
        <foreign xml:lang="de">Hervorgehoben</foreign>
        <foreign xml:lang="en">highlighted</foreign>
        </tei:hi>
        </tei:tei>;


(:!!!!! DON'T CHANGE THE SETTINGS BELOW !!!!!:)

(: Styleshets :)
declare variable $archeao18conf:stylesheetXhtml := 'TEI2XHTML.xsl';
declare variable $archeao18conf:stylesheetKml := 'gettyQuery.xsl';
declare variable $archeao18conf:stylesheetStructure := 'structureExtractor.xsl';
declare variable $archeao18conf:stylesheetBreak := 'removeBreaks.xsl';
(: Stylesheets used by import :)
declare variable  $archeao18conf:stylesheetImportEnrichStylesheet := "enrichment.xsl";
declare variable  $archeao18conf:stylesheetImportEnrichMetadataStylesheet := "metadata-enrichment.xsl";
declare variable  $archeao18conf:stylesheetImportMetsStylesheet := "mets-2.0.xsl";

(: Computed paths :)
declare variable $archeao18conf:dataBase := concat($archeao18conf:base, $archeao18conf:dataPrefix);
declare variable $archeao18conf:transformationsBase := concat($archeao18conf:base, $archeao18conf:transformationsPrefix);
declare variable $archeao18conf:queriesBase := concat($archeao18conf:base, $archeao18conf:queriesPrefix);
declare variable $archeao18conf:transformationRestBase := concat($archeao18conf:restBase, $archeao18conf:transformationsBase);
declare variable $archeao18conf:cacheBase := concat($archeao18conf:dataBase, $archeao18conf:cachePrefix);
declare variable $archeao18conf:schemaBase := concat($archeao18conf:base, $archeao18conf:configPrefix, $archeao18conf:schemaPrefix);
declare variable $archeao18conf:schemaCacheBase := concat($archeao18conf:dataBase, $archeao18conf:cachePrefix, $archeao18conf:schemaPrefix);

(: Computed HTTP specific configuration :)
(: Find out if the query was called via HTTP :)
declare variable $archeao18conf:httpIsRequest := if (not(util:catch('*', request:get-context-path(), false()) instance of xs:boolean)) then
                                                    true()
                                                 else
                                                    false();
(: Find out which query was called (local path inside the database) :)                      
declare variable $archeao18conf:httpLocalCallPath := if ($archeao18conf:httpIsRequest) then
                                                        request:get-servlet-path()
                                                     else
                                                        '';
(: Reconstruct the REST path to the query :)                                                        
declare variable $archeao18conf:httpRestCallPath := if ($archeao18conf:httpIsRequest) then 
                                                        if (starts-with($archeao18conf:restBase, request:get-context-path())) then
                                                            concat($archeao18conf:restBase, $archeao18conf:httpLocalCallPath)
                                                        else
                                                            let $restServlet := concat ('/', substring-after(substring-after($archeao18conf:restBase, '/'), '/'))
                                                            return concat(request:get-context-path(), $restServlet, $archeao18conf:httpLocalCallPath)
                                                    else
                                                        '';
                                                     
(: Internal tweaks :)
(: Prefered namespace prefix for TEI :)
declare variable $archeao18conf:teiNamespacePrefix := 'TEI:';