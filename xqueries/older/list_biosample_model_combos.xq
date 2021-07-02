declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $bsmodel in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Models/Model
let $attribname :=  data(
  $bsmodel
)
let $bs := $bsmodel/../..
let $bsaccession := data(
  $bs/@accession
)

return 
<csv>
<record>
<accession>{
  $bsaccession
}</accession>
<model>{
  $attribname
}</model>
</record></csv>
