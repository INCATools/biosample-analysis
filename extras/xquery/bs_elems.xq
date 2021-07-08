let $sep := '&#09;' (: tab :)
for $bs in doc('biosample_set')/BioSampleSet/BioSample
let $elems := $bs/*
for $current in $elems
return(name($current))
