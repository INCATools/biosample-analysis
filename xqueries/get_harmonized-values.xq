declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";
declare variable $min_bs_id_val as xs:int+ external;
declare variable $max_bs_id_val as xs:int+ external;
declare variable $delim external;

(:let $delim := "|||":)

(:
for "potentially_shared"
let $delim := ""
one pipe
three pipes
soemthing else?
:)

for $bs in doc(
  'biosample_set_basex'
)/BioSampleSet/BioSample

(: [@accession='SAMN10712958'] :)

let $bs_id_val := data(
  $bs/@id
)

let $legacy_id := concat("BIOSAMPLE:",data($bs/Ids/Id[@is_primary = "1"]))

where xs:integer(
  $bs_id_val
) > $min_bs_id_val
and xs:integer(
  $bs_id_val
) < $max_bs_id_val

for $uhn_val in distinct-values(
  $bs/Attributes/Attribute[@harmonized_name]/@harmonized_name
)
let $x := data(
  $bs/Attributes/Attribute[@harmonized_name=$uhn_val]
)
(: lower-case? :)
let $potentially_shared := fn:normalize-space(
  string-join(
    sort(
      distinct-values(
        $x
      )
    ),$delim
  )
)

order by xs:integer(
  $bs_id_val
), $uhn_val

return 

<csv><record> 
<id>{
  $bs_id_val
}</id>
<attribute>{
  $uhn_val
}</attribute>
<value>{
  $potentially_shared
}</value>
</record></csv>
