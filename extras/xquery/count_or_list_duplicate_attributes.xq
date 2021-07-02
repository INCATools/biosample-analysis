declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

let $attrib_hn_val := 'analyte_type'
for $attrib in doc('biosample_set_2M_lines')/BioSampleSet/BioSample/Attributes/Attribute[@harmonized_name=$attrib_hn_val]
let $attrib_hn := data($attrib/@harmonized_name)
let $attrib_val := data($attrib)
let $bs := $attrib/../..
let $accession := data($bs/@accession)

group by $accession
order by count($attrib_val) descending

return <csv><record>
<accession>{$accession}</accession>
<tissue>{count($attrib_val)}</tissue>
</record></csv>


(: return <csv><record>
<accession>{$accession}</accession>
<tissue>{$attrib_val}</tissue>
</record></csv> :)

