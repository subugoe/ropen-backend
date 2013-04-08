xquery version "1.0";
module namespace r = "http://mattiovalentino.com/xquery/roman/";

(: Thanks to Marko Schulz for seeding this idea with his JavaScript version at http://vimeo.com/16935085. :)

declare function r:roman( $input as xs:string ) as xs:integer
{
	let $characters := r:convert-string-to-characters(upper-case($input))
	
	let $numbers := 
		for $i in $characters 
		return 
			r:convert-string-to-integer($i)

	let $total := 
		for $i at $count in $numbers 
		return 
			if($i < $numbers[$count + 1]) then (-$i) (: Handles subtractive principle of Roman numerals. :)
			else $i
	
	return sum($total)
};

(: Saxon didn't seem to like my use of local: here. Why? What am I missing? :)
declare function r:convert-string-to-integer( $input as xs:string ) as xs:integer
{
	(: Seems like a hacky way to implement a switch-like statement. Is there a better way? 
	   My earlier version was for $i in 1 to 1 return ... :)
	let $results :=
		if($input = "I") then 1
		else if($input = "V") then 5
		else if($input = "X") then 10
		else if($input = "L") then 50
		else if($input = "C") then 100
		else if($input = "D") then 500
		else if($input = "M") then 1000
		else 0		
	return $results
};

(: From http://www.xqueryfunctions.com/xq/functx_chars.html :)
declare function r:convert-string-to-characters( $input as xs:string ) as xs:string*
{
	for $c in string-to-codepoints($input)
	return codepoints-to-string($c)
};