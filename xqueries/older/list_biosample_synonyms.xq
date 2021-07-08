declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $syn_node in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Description/Synonym

let $bs := $syn_node/../..
let $bs_id := data($bs/@id)
let $syn_db := data($syn_node/@db)
let $syn := data($syn_node)

(: group by $bs_id
order by count($syn) descending :)

return 

<result><csv>
<bs_id>{$bs_id}</bs_id>
<syn_db>{$syn_db}</syn_db>
<syn>{$syn}</syn>
</csv></result>

(:
<bs_id>{$bs_id}</bs_id>
<syn>{count($syn)}</syn> :)