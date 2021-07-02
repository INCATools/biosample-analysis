declare namespace uuid = "java:java.util.UUID";

let $sep := '&#09;' (: tab :)
for $bs in doc('biosample_set')/BioSampleSet/BioSample
let $bsuuid := uuid:randomUUID()
for $id in $bs/Ids/Id
let $iduuid := uuid:randomUUID()
let $idattrib := $id/@*
for $oia in $idattrib

return string-join(
       (
        $bsuuid,
        $iduuid,
        name($oia),
        string($oia)   
       ),
       $sep)