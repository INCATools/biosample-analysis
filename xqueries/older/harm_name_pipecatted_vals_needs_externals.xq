declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";
declare variable $min_bs_id_val as xs:int+ external;
declare variable $max_bs_id_val as xs:int+ external;

for $bs in doc(
  'biosample_set'
)/BioSampleSet/BioSample

(: [@accession='SAMN10712958'] :)

let $bs_id_val := data(
  $bs/@id
)

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
    ),'|'
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

(: 
see also

max(
  for $bss in doc(
     'biosample_set' 
  )/BioSampleSet
return data(
    $bss/BioSample/@id
  )
)

:)
