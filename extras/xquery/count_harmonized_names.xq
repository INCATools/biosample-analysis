declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $attrib in doc('biosample_set_2M_lines')/BioSampleSet/BioSample/Attributes/Attribute[@harmonized_name]
let $attrib_hn := data($attrib/@harmonized_name)

(: return $attrib_hn :)

group by $attrib_hn
order by count($attrib) descending

return <csv><record>
<attrib_hn>{$attrib_hn}</attrib_hn>
<attrib_count>{count($attrib)}</attrib_count>
</record></csv>