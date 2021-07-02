declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";


for $bsattrib in doc(
  'biosample_set'
)/BioSampleSet/BioSample/@*
let $attribname :=  name(
  $bsattrib
)
let $bs := $bsattrib/..

group by $attribname
order by count($bs) descending

return <csv><record>
<bs_attrib>{
  $attribname
}</bs_attrib>
<count>{
  count(
    $bs
  )
}</count>
</record></csv>
