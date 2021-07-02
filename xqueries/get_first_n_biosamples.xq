declare variable $maxent as xs:int+ external;

"<BioSampleSet>",

(: 
expecting about 18 000 000 biosample elements
how to get that within this query?
:)

(: let $expected := 18000000
let $keepfrac := 0.01
let $maxent := $expected / $keepfrac :)

(: also, how to insert back into database
instead of saving as file and loading from that file into a new db? :)

for $bs in doc(
  'biosample_set_basex'
)/BioSampleSet/BioSample[position() lt $maxent]

return $bs,

"</BioSampleSet>"