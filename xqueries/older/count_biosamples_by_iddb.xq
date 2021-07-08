declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $id in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Ids/Id
let $bs := $id/../..
let $iddb := data(
  $id/@db
)

group by $iddb
order by count(
      $bs
    ) descending

return <csv><record>
<id_db>{
  $iddb
}</id_db>
<biosample_count>{
  count(
    $bs
  )
}</biosample_count>
</record></csv>
