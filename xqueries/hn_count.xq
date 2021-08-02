declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $hn in doc(
  'biosample_set_basex'
)/BioSampleSet/BioSample/Attributes/Attribute[@harmonized_name]/@harmonized_name

let $hnhn := data(
  $hn
)

group by $hnhn

let $count := count(
  $hn
)

return 

<result>
	<csv>
		<hn>{
  $hnhn
}</hn>		<count>{
  $count
}</count></csv></result>
