let $sep := '&#09;' (: tab :)

for $Attribute in doc('BioSampleAttributes')/BioSampleAttributes/Attribute
let $Name := $Attribute/Name
let $HarmonizedName := $Attribute/HarmonizedName

return string-join(
       (
        $Name,
        $HarmonizedName
       ),
       $sep)

