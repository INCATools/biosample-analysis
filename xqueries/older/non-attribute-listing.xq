declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $element in doc(
  'biosample_set'
)/BioSampleSet/BioSample

let $biosample_id := fn:normalize-space( data($element/@id))
let $last_update :=  fn:normalize-space(data($element/@last_update))
let $access :=  fn:normalize-space(data($element/@access))
let $publication_date :=  fn:normalize-space(data($element/@publication_date))
let $accession :=  fn:normalize-space(data($element/@accession))
let $submission_date :=  fn:normalize-space(data($element/@submission_date))
let $is_reference :=  fn:normalize-space(data($element/@is_reference))

let $primary_id_element :=  fn:normalize-space($element/Ids/Id[@is_primary="1"])
let $primary_id_data := fn:normalize-space(data($primary_id_element))

let $title := fn:normalize-space(data($element/Description/Title))

let $taxonomy_id := fn:normalize-space(data($element/Description/Organism/@taxonomy_id))
let $taxonomy_name := fn:normalize-space(data($element/Description/Organism/@taxonomy_name))
let $organism_name_cat := fn:normalize-space(string-join(data($element/Description/Organism/OrganismName),"|"))


let $package := fn:normalize-space(data($element/Package))
let $package_display_name := fn:normalize-space(data($element/Package/@display_name))

let $model_cat := fn:normalize-space(string-join(data($element/Models/Model),"|"))
let $model_version_cat := fn:normalize-space(string-join(data($element/Models/Model/@version),"|"))

let $paragraph_cat := fn:normalize-space(string-join(data($element/Description/Comment/Paragraph),"|"))

let $status := fn:normalize-space($element/Status/@status)
let $when := fn:normalize-space($element/Status/@when)

let $curation_date := fn:normalize-space($element/Curation/@curation_date)
let $curation_status := fn:normalize-space($element/Curation/@curation_status)


(: externally check if any biosample ids are repeated
that would mean that multidata hadn't been accounted for:)

(: do we want special handling of description paragraphs that start with "keywords":)
return

 (: $paragraph_cat :)

<result><csv>

<biosample_id>{$biosample_id}</biosample_id>
<primary_id_data>{$primary_id_data}</primary_id_data>
<accession>{$accession}</accession>

<title>{$title}</title>

<taxonomy_id>{$taxonomy_id}</taxonomy_id>
<taxonomy_name>{$taxonomy_name}</taxonomy_name>
<organism_name_cat>{$organism_name_cat}</organism_name_cat>

<model_cat>{$model_cat}</model_cat>
<model_version_cat>{$model_version_cat}</model_version_cat>

<package>{$package}</package>
<package_display_name>{$package_display_name}</package_display_name>

<access>{$access}</access>
<is_reference>{$is_reference}</is_reference>

<submission_date>{$submission_date}</submission_date>
<publication_date>{$publication_date}</publication_date>
<last_update>{$last_update}</last_update>

<status>{$status}</status>
<when>{$when}</when>

<curation_date>{$curation_date}</curation_date>
<curation_status>{$curation_status}</curation_status>

<paragraph_cat>{$paragraph_cat}</paragraph_cat>

</csv></result>

(: <paragraph_cat>{$paragraph_cat}</paragraph_cat> :)

