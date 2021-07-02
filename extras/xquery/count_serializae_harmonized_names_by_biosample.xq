declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $bsattrib in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Attributes/Attribute

let $attribdata := data(
  $bsattrib
)
let $attrib_name := data(
  $bsattrib/@attribute_name
)
let $attrib_hn := data(
  $bsattrib/@harmonized_name
)
let $bs := $bsattrib/../..
let $bsaccession := data(
  $bs/@accession
)

group by $attrib_hn

order by  count(
  $bs
) descending

return <csv><record>
<hname>{$attrib_hn}</hname>
<bs_count>{count($bs)}</bs_count>
</record></csv>
