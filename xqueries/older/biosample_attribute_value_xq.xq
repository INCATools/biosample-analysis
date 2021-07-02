declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

(: _2M_lines :)
for $bsattrib in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Attributes/Attribute[@harmonized_name]

let $ahn := data(
  $bsattrib/@harmonized_name
)
let $adata := data(
  $bsattrib
)
let $accession := data(
  $bsattrib/../../@accession
)

return <csv><record>
<accession>{
  $accession
}</accession>
<harmonized_name>{
  $ahn
}</harmonized_name>
<attribute_value>{
  $adata
}</attribute_value>
</record>
</csv>

