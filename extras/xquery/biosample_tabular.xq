declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $bs in doc(
  'biosample_set'
)/BioSampleSet/BioSample

let $accession := data(
  $bs/@accession
)
let $primary_id := $bs/Ids/Id[@is_primary]
let $primary_id_val := data(
  $primary_id
)
let $org_tax_id := data(
  $bs/Description/Organism/@taxonomy_id
)

let $descr_paragraphs := string-join(data($bs/Description/Comment/Paragraph),"|")

let $title := data(
  $bs/Description/Title
)

let $org_tax_name := data(
  $bs/Description/Organism/@taxonomy_name
)
(: description paragraphs:)

let $package := data(
  $bs/Package
)

(: multiple models possible, like SAMN00001340 :)
let $model := string-join(data($bs/Models/Model),"|")

(: package and package display name always 1:1 agreement
do we need both?:)
let $package_disp_name := data(
  $bs/Package/@display_name
)
(: can a sample have two or more of the same attribute?
casual querying suggests no:)
let $env_package_attrib := data(
  $bs/Attributes/Attribute[@harmonized_name='env_package']
)
let $env_broad_scale := data(
  $bs/Attributes/Attribute[@harmonized_name='env_broad_scale']
)
let $env_local_scale := data(
  $bs/Attributes/Attribute[@harmonized_name='env_local_scale']
)
let $env_medium := data(
  $bs/Attributes/Attribute[@harmonized_name='env_medium']
)

let $host_taxid := data(
  $bs/Attributes/Attribute[@harmonized_name='host_taxid']
)

return <csv><record>
<accession>{
  $accession
}</accession>
<primary_id>{
  $primary_id_val
}</primary_id>

<title>{$title}</title>

<descr_paragraphs>{$descr_paragraphs}</descr_paragraphs>

<model>{$model}</model>
<org_tax_id>{
  $org_tax_id
}</org_tax_id>
<org_tax_name>{
  $org_tax_name
}</org_tax_name>
<package>{
  $package
}</package>
<package_disp_name>{
  $package_disp_name
}</package_disp_name>
<env_package_attrib>{
  $env_package_attrib
}</env_package_attrib>

<env_broad_scale>{
  $env_broad_scale
}</env_broad_scale>
<env_local_scale>{
  $env_local_scale
}</env_local_scale>
<env_medium>{
  $env_medium
}</env_medium>

<host_taxid>{
  $host_taxid
}</host_taxid>

</record></csv>
