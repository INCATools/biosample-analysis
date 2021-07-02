declare namespace uuid = "java:java.util.UUID";

let $sep := '&#09;' (: tab :)
for $bs in doc('biosample_set_2M_lines')/BioSampleSet/BioSample
let $bsuuid := uuid:randomUUID()
for $id in $bs/Ids/Id
let $iduuid := uuid:randomUUID()
let $idattrib := $id/@*
for $oia in $idattrib

return string-join(
       (
        name($oia),
        string($oia)   
       ),
       $sep)