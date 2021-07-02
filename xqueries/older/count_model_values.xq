declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $bsmodel in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Models/Model
let $attribname :=  data(
  $bsmodel
)
group by $attribname
order by count(
  $bsmodel
) descending

return <csv><record>
<model>{
  $attribname
}</model>
<count>{
  count(
    $bsmodel
  )
}</count>
</record></csv>

