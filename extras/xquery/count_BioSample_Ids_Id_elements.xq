"element_name&#09;count",

(: 
or use a smaller database: biosample_set_2M_lines

June 2021 takes ~ 0.5 minutes
:)

let $sep := '&#09;' (: tab :)

for $element in doc(
  'biosample_set'
)/BioSampleSet/BioSample/Ids/Id/*

let $element_name := name($element)
group by $element_name 
order by count($element) descending

return string-join(
       (
       $element_name, count(
      $element
    )
       ),
       $sep[1]
)