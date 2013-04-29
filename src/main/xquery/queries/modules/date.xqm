xquery version "1.0";

module namespace date="http://archaeo18.sub.uni-goettingen.de/exist/date";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace strings = "http://archaeo18.sub.uni-goettingen.de/exist/strings" at "./strings.xqm";
import module namespace r = "http://mattiovalentino.com/xquery/roman/" at "./roman-numerals.xqm";

declare function date:parse-date ($str as xs:string) as xs:string {
    let $beforeChrist := ('[vV].\s*?[cC].\s*?[gG].', 'J. vor C.\s*?G.', 'vor\s*?Christi\s*?Geburt', 'Jahr[e]?\s*?vor\s*?Christi', 'ante\s*?C[hr.]', '[Aa].\s*?[Cc].\s*?[Nn].', 'v.\s*?Chr.', 'before\s*?Christ')
    let $olypiaTime := ('Ol.', 'Olymp')
    let $centuryTerm := ('[Ss][eæ]cul[io]', 'Centuries', 'Jahrunderte?', 'Jhdts?', 'Saec')
    let $yearIndicator := ('[Aa]o', 'a.', '[Aa]nno')
    let $rangeIndicator := ('bis', '-', '\d{2,}[^\d]*\d{2,}')
    let $dateSeperator := '-'
    let $romanIndicator := ('')
    
    let $monthsTerm := <months>
                           <month match="1" pattern="\s?[Jj]an[\w.]*?\s?"/>
                           <month match="2" pattern="\s?[Ff]eb[\w.]*?\s?"/>
                           <month match="3" pattern="\s?[Mm]ar[\w.]*?\s?"/>
                           <month match="4" pattern="\s?[Aa]pr[\w.]*?\s?"/>
                           <month match="5" pattern="\s?[Mm]ai[\w.]*?\s?"/>
                           <month match="6" pattern="\s?[Jj]un[\w.]*?\s?"/>
                           <month match="7" pattern="\s?[Jj]ul[\w.]*?\s?"/>
                           <month match="8" pattern="\s?[Aa]ug[\w.]*?\s?"/>
                           <month match="9" pattern="\s?[Ss]ept[\w.]*?\s?"/>
                           <month match="10" pattern="\s?[Oo][ck]t[\w.]*?\s?"/>
                           <month match="11" pattern="\s?[Nn]ov[\w.]*?\s?"/>
                           <month match="12" pattern="\s?[Dd]e[cz][\w.]*?\s?"/>
                       </months>

    let $clearedDate := replace($str, '[^\d]', '')
    let $computedYear := if (string-length($str) = 4 and $str castable as xs:gYear) then $str
                         else if (strings:match-sequence-any($str, $yearIndicator)) then replace($str, '[^\d]', '')
                         else if (string-length($clearedDate) = 4 and matches($str, '\d{4}') and $clearedDate castable as xs:gYear) then $clearedDate
                         else if (string-length($str) = 3) then $str
                         else if (string-length($clearedDate) = 3 and matches($str, '\d{3}') ) then $clearedDate
                         else if (matches($str, '^\d*$')) then $str
                         else if (matches($str, '\d{4}')) then replace($str, '.*?(\d{4}).*', '$1')
                         else ''

    let $computedYear := if (strings:match-sequence-any($str, $beforeChrist)) then concat('-', $computedYear)
                         else $computedYear
    
    (: Compute the remaining string - remove year:)
    let $str := if ($computedYear != '') then
                    replace($str, replace($computedYear, '-', ''), '')
                else $str
                
    let $str := strings:replace-sequence($str, $beforeChrist)
    
    let $log := util:log('DEBUG', concat('Year is ', $computedYear, ' remaining string (after cleanup of BC) ', $str))
    
    (:TODO: Make the calculation of centuries work :)
    (:
    let $centuryDate := if (strings:match-sequence-any($str, $centuryTerm)) then
                            true()
                        else
                            false()
    :)
    
    let $computedYear := if ($computedYear = '-' and strings:match-sequence-any($str, $centuryTerm)) then
                            concat('-', string(xs:integer(replace($str, '[^\d]*', '')) * 100))
                         else if ($computedYear != '' and strings:match-sequence-any($str, $centuryTerm)) then
                            string(xs:integer(replace($computedYear, '-', '')) * 100)
                         else $computedYear
    
    let $computedMonth := if ($computedYear != '' and strings:match-sequence-any($str, $monthsTerm//*/@pattern)) then
                            strings:find-first-match ($str, $monthsTerm)
                          else 
                            '0'
                            
    (: Compute the remaining string - remove month :)
    let $str := strings:replace-sequence($str, $monthsTerm//*/@pattern)
    
    let $log := util:log('DEBUG', concat('Computed year is ', $computedYear, ', month ', $computedMonth, ' remaining string (after cleanup of BC) ', $str))
    
    let $computedDay := if (matches($str, '\d{1,2}')) then replace($str, '.*?(\d{1,2}).*', '$1')
                        else '0'

    let $suspicious := if (strings:match-sequence-any($str, $olypiaTime) or strings:match-sequence-any($str, $centuryTerm) or strings:match-sequence-any($str, $rangeIndicator)) then true()
                       else false()
    
    let $computedDate := if ($computedYear != '' and $computedMonth != '0' and $computedDay != '0') then
                            concat($computedYear, $dateSeperator, $computedMonth, $dateSeperator, $computedDay)
                         else if ($computedYear != '' and $computedMonth != '0') then 
                            concat($computedYear, $dateSeperator, $computedMonth)
                         else if  ($computedYear != '') then $computedYear
                         else ''
    
    return if ($suspicious = false()) then $computedDate
            else ''
};

(:
declare function date:parse-date ($str as xs:string) as xs:string {
    let $beforeChrist := ('[vV].\s*?[cC].\s*?[gG].', 'J. vor C.\s*?G.', 'vor\s*?Christi\s*?Geburt', 'Jahr[e]?\s*?vor\s*?Christi', 'ante\s*?C[hr.]', '[Aa].\s*?[Cc].\s*?[Nn].', 'v.\s*?Chr.')
    let $olypiaTime := ('Ol.', 'Olymp')
    let $centuryTerm := ('[Ss][eæ]cul[io]', 'Centuries', 'Jahrunderte', 'Jhdts')
    let $yearIndicator := ('[Aa]o', 'a.', '[Aa]nno')
    let $rangeIndicator := ('bis', '-', '\d{2,}[^\d]*\d{2,}')
    let $dateSeperator := '-'
    
    let $monthsTerm := <months>
                           <month match="1" pattern="\s?[Jj]an[\w.]*?\s?"/>
                           <month match="2" pattern="\s?[Ff]eb[\w.]*?\s?"/>
                           <month match="3" pattern="\s?[Mm]ar[\w.]*?\s?"/>
                           <month match="4" pattern="\s?[Aa]pr[\w.]*?\s?"/>
                           <month match="5" pattern="\s?[Mm]ai[\w.]*?\s?"/>
                           <month match="6" pattern="\s?[Jj]un[\w.]*?\s?"/>
                           <month match="7" pattern="\s?[Jj]ul[\w.]*?\s?"/>
                           <month match="8" pattern="\s?[Aa]ug[\w.]*?\s?"/>
                           <month match="9" pattern="\s?[Ss]ept[\w.]*?\s?"/>
                           <month match="10" pattern="\s?[Oo][ck]t[\w.]*?\s?"/>
                           <month match="11" pattern="\s?[Nn]ov[\w.]*?\s?"/>
                           <month match="12" pattern="\s?[Dd]e[cz][\w.]*?\s?"/>
                       </months>

    let $clearedDate := replace($str, '[^\d]', '')
    let $computedYear := if (string-length($str) = 4 and $str castable as xs:gYear) then $str
                         else if (strings:match-sequence-any($str, $yearIndicator)) then replace($str, '[^\d]', '')
                         else if (string-length($clearedDate) = 4 and matches($str, '\d{4}') and $clearedDate castable as xs:gYear) then $clearedDate
                         else if (string-length($str) = 3) then $str
                         else if (string-length($clearedDate) = 3 and matches($str, '\d{3}') ) then $clearedDate
                         else if (matches($str, '^\d*$')) then $str
                         else if (matches($str, '\d{4}')) then replace($str, '.*?(\d{4}).*', '$1')
                         else '0'

    let $computedYear := if (strings:match-sequence-any($str, $beforeChrist)) then concat('-', $computedYear)
                         else if ($computedYear = '') then '0'
                         else $computedYear
                         
    (: Compute the remaining string - remove year:)
    let $str := replace($str, replace($computedYear, '-', ''), '')
    let $str := strings:replace-sequence($str, $beforeChrist)
                         
    let $computedYear := if (strings:match-sequence-any($str, $centuryTerm) and $computedYear != '') then string(xs:integer(replace($computedYear, '-', '')) * 100)
                         else $computedYear
    
    let $computedMonth := if ($computedYear != '' and strings:match-sequence-any($str, $monthsTerm//*/@pattern)) then strings:find-first-match ($str, $monthsTerm)
                          else '0'
    (: Compute the remaining string - remove month :)
    let $str := strings:replace-sequence($str, $monthsTerm//*/@pattern)
    
    let $computedDay := if (matches($str, '\d{1,2}')) then replace($str, '.*?(\d{1,2}).*', '$1')
                        else '0'

    let $suspicious := if (strings:match-sequence-any($str, $olypiaTime) or strings:match-sequence-any($str, $centuryTerm) or strings:match-sequence-any($str, $rangeIndicator)) then true()
                       else false()
    
    let $computedDate := if ($computedYear != '0' and $computedMonth != '0' and $computedDay != '0') then
                            concat($computedYear, $dateSeperator, $computedMonth, $dateSeperator, $computedDay)
                         else if ($computedYear != '0' and $computedMonth != '0') then 
                            concat($computedYear, $dateSeperator, $computedMonth)
                         else if  ($computedYear != '0') then $computedYear
                         else ''
    
    return if ($suspicious = false()) then $computedDate
            else ''
};
:)
declare function date:date-entry ($dateStr as xs:string, $addEntries as element()?) as element() {
        let $parsed-date := if ($dateStr != '') then date:parse-date($dateStr)
                            else ''
        return
        <xhtml:div class="date">
            <xhtml:span class="displayDate">{$dateStr}</xhtml:span>
            <xhtml:span class="computedDate">{$parsed-date}</xhtml:span>
            {
            if (empty($addEntries)) then
                ()
            else $addEntries
            
            }
        </xhtml:div>
};