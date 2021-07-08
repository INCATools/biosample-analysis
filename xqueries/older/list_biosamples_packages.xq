declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $bspack in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Package
let $attribdata :=  data(
  $bspack
)
let $attrib_dn := data($bspack/@display_name)
let $bs := $bspack/..
let $bsaccession := data(
  $bs/@accession
)

return <csv><record>
<accession>{
  $bsaccession
}</accession>
<package_disp_name>{
  $attrib_dn
}</package_disp_name>
<package>{
  $attribdata
}</package>
</record>
</csv>

