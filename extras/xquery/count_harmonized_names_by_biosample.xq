(:

 :)

"harmonized_name&#09;count",

let $sep := '&#09;' (: tab :)

(: _2M_lines :)
(: ignores non narmonized attributes:)
for $bsattrib in doc('biosample_set')/BioSampleSet/BioSample/Attributes/Attribute[@harmonized_name]
let $attribdata := data($bsattrib)
let $attrib_name := data($bsattrib/@attribute_name)
let $attrib_hn := data($bsattrib/@harmonized_name)
let $bs := $bsattrib/../..
let $bsaccession := data($bs/@accession)

group by $attrib_hn
order by  count($bs) descending

(: return  $attrib_hn :)

return string-join(
       (
       $attrib_hn, count($bs)
       ),
       $sep[1])