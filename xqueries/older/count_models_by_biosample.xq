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

group by $bsaccession
order by count(
  $attribname
) descending

return <csv><record>
<accession>{
  $bsaccession
}</accession>
<count>{
  count(
    $attribname
  )
}</count>
</record></csv>

