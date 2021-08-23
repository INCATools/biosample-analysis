declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $id in doc('biosample_set')/BioSampleSet/BioSample/Ids/Id
let $id_value := data($id)
let $db_name := data($id/@db)
let $parent_id_set := $id/..
let $primary_id := $parent_id_set/Id[@is_primary='1']
let $primary_id_value := data($primary_id)
let $is_primary := data($id/[@is_primary])
let $db_label := data($id/[@db_label])
let $is_hidden := data($id/[@is_hidden])
let $bs := $id/../..
let $accession := data($bs/@accession)

return <csv><record>
<accession>{$accession}</accession>
<primary_id_value>{$primary_id_value}</primary_id_value>
<db_name>{$db_name}</db_name>
<id_value>{$id_value}</id_value>
<is_primary>{$is_primary}</is_primary>
<db_label>{$db_label}</db_label>
<is_hidden>{$is_hidden}</is_hidden>
</record></csv>
