declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $element in doc(
  'biosample_set_basex'
)/BioSampleSet/BioSample

let $biosample_id := fn:normalize-space( data($element/@id))
(: let $last_update :=  fn:normalize-space(data($element/@last_update))
let $access :=  fn:normalize-space(data($element/@access))
let $publication_date :=  fn:normalize-space(data($element/@publication_date)) :)
let $accession :=  fn:normalize-space(data($element/@accession))
(: let $submission_date :=  fn:normalize-space(data($element/@submission_date)) :)
(: let $is_reference :=  fn:normalize-space(data($element/@is_reference)) :)

let $primary_id_element :=  fn:normalize-space($element/Ids/Id[@is_primary="1"])
let $primary_id_data := fn:normalize-space(data($primary_id_element))

let $title := fn:normalize-space(data($element/Description/Title))

let $taxonomy_id := fn:normalize-space(data($element/Description/Organism/@taxonomy_id))
let $taxonomy_name := fn:normalize-space(data($element/Description/Organism/@taxonomy_name))

(: let $organism_name_cat := fn:normalize-space(string-join(data($element/Description/Organism/OrganismName),"|")) :)

let $package := fn:normalize-space(data($element/Package))
let $package_display_name := fn:normalize-space(data($element/Package/@display_name))

let $model_cat := fn:normalize-space(string-join(data($element/Models/Model),"|"))

(: let $model_version_cat := fn:normalize-space(string-join(data($element/Models/Model/@version),"|")) :)

let $paragraph_cat := fn:normalize-space(string-join(data($element/Description/Comment/Paragraph),"|"))

let $status := fn:normalize-space($element/Status/@status)
let $when := fn:normalize-space($element/Status/@when)

(: let $curation_date := fn:normalize-space($element/Curation/@curation_date)
let $curation_status := fn:normalize-space($element/Curation/@curation_status) :)

let $entrez_label :=fn:normalize-space(string-join(data($element/Links/Link[@type="entrez"]/@label),"|"))
let $entrez_target :=fn:normalize-space(string-join(distinct-values($element/Links/Link[@type="entrez"]/@target),"|"))
let $entrez_value := fn:normalize-space(string-join(data($element/Links/Link[@type="entrez"]),"|"))

let $doi := data($element/Links/Link[@label="DOI"])

let $dna_source := data($element/Links/Link[@type="url" and @label="DNA Source"])


(: externally check if any biosample ids are repeated
that would mean that multidata hadn't been accounted for:)

(: do we want special handling of description paragraphs that start with "keywords":)
return

 (: get distinct values for entrez etc links like we did for model:) 
 (: but looses ordering? not making distinct yet :)
 (: triple pipes?:)

<result><csv>

<id>{$biosample_id}</id>
<primary_id>{$primary_id_data}</primary_id>
<accession>{$accession}</accession>
<title>{$title}</title>
<entrez_label>{$entrez_label}</entrez_label>
<entrez_target>{$entrez_target}</entrez_target>
<entrez_value>{$entrez_value}</entrez_value>
<doi>{$doi}</doi>
<dna_source>{$dna_source}</dna_source>
<model>{$model_cat}</model>
<package>{$package}</package>
<package_name>{$package_display_name}</package_name>

<taxonomy_id>{$taxonomy_id}</taxonomy_id>
<taxonomy_name>{$taxonomy_name}</taxonomy_name>
<status>{$status}</status>
<status_date>{$when}</status_date>

<paragraph>{$paragraph_cat}</paragraph>

</csv></result>
