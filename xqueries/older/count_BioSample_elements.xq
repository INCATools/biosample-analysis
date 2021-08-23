declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $element in doc(
  'biosample_set'
)/BioSampleSet/BioSample/*

let $bs := $element/..

let $element_name := name($element)
group by $element_name 
order by count($bs) descending

return <csv><record>
<element_name>{$element_name}</element_name>
<element_count>{count($bs)}</element_count>
</record></csv>