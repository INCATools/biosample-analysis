declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";


for $bs_hn_attrib in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Attributes/Attribute[@harmonized_name]

let $bs_id := fn:normalize-space(data(
  $bs_hn_attrib/../../@id
))

let $ahn := fn:normalize-space(data(
  $bs_hn_attrib/@harmonized_name
))

let $adata := fn:normalize-space(data(
  $bs_hn_attrib
))


return <csv><record>
<id>{
  $bs_id
}</id>
<attribute>{
  $ahn
}</attribute>
<value>{
  $adata
}</value>
</record>
</csv>

