let $sep := '&#09;' (: tab :)

for $bs in doc(
  'biosample_set_2M_lines'
)/BioSampleSet/BioSample

let $elems := $bs/*

for $current in $elems
let $currname := name(
  $current
)
group by $current

return string-join(
       (
        $currname,
        count(
      $bs
    )
       ),
       $sep
)
