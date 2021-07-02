declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $idattrib in doc('biosample_set')/BioSampleSet/BioSample/Ids/Id/@*
let $attribname :=  name($idattrib)
group by $attribname
order by count($idattrib) descending

return <csv><record>
<attribute_name>{$attribname}</attribute_name>
<attribute_count>{count($idattrib)}</attribute_count>
</record></csv>

