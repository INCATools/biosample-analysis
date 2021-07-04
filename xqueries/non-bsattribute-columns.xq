declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

for $element in doc(
  'biosample_set_basex'
)/BioSampleSet/BioSample


(: let $access :=  fn:normalize-space(data($element/@access)) :)
(: let $curation_date := fn:normalize-space($element/Curation/@curation_date)
(: let $curation_status := fn:normalize-space($element/Curation/@curation_status) :) :)
(: let $is_reference :=  fn:normalize-space(data($element/@is_reference)) :)
(: let $last_update :=  fn:normalize-space(data($element/@last_update))
(: let $model_version_cat := fn:normalize-space(string-join(data($element/Models/Model/@version),"|||")) :)
(: let $organism_name_cat := fn:normalize-space(string-join(data($element/Description/Organism/OrganismName),"|||")) :)
(: let $publication_date :=  fn:normalize-space(data($element/@publication_date)) :) :)
(: let $submission_date :=  fn:normalize-space(data($element/@submission_date)) :)

let $accession :=  fn:normalize-space(string-join(data($element/@accession),"|||"))
let $biosample_id := fn:normalize-space(string-join(data($element/@id),"|||"))
let $dna_source := fn:normalize-space(string-join(data($element/Links/Link[@type="url" and @label="DNA Source"]),"|||"))
let $doi := fn:normalize-space(string-join(data($element/Links/Link[@label="DOI"]),"|||"))

let $entrez_label :=fn:normalize-space(string-join(data($element/Links/Link[@type="entrez"]/@label),"|||"))
let $entrez_target :=fn:normalize-space(string-join(distinct-values($element/Links/Link[@type="entrez"]/@target),"|||"))
let $entrez_value := fn:normalize-space(string-join(data($element/Links/Link[@type="entrez"]),"|||"))

let $model_cat := fn:normalize-space(string-join(data($element/Models/Model),"|||"))
let $package := fn:normalize-space(string-join(data($element/Package),"|||"))
let $package_display_name := fn:normalize-space(string-join(data($element/Package/@display_name),"|||"))
let $paragraph_cat := fn:normalize-space(string-join(data($element/Description/Comment/Paragraph),"|||"))

(: let $primary_id_element := $element/Ids/Id[@is_primary="1"]
let $primary_id_data := fn:normalize-space(data($primary_id_element)) :)

let $primary_id_data := fn:normalize-space(string-join(data($element/Ids/Id[@is_primary="1"]),"|||"))

let $status := fn:normalize-space(string-join(data($element/Status/@status),"|||"))
let $taxonomy_id := fn:normalize-space(string-join(data($element/Description/Organism/@taxonomy_id),"|||"))
let $taxonomy_name := fn:normalize-space(string-join(data($element/Description/Organism/@taxonomy_name),"|||"))
let $title := fn:normalize-space(string-join(data($element/Description/Title),"|||"))
let $when := fn:normalize-space(string-join(data($element/Status/@when),"|||"))


(: externally check if any biosample ids are repeated
that would mean that multidata hadn't been accounted for:)

(: do we want special handling of description paragraphs that start with "keywords":)

(: get distinct values for entrez etc links like we did for model:) 
(: but looses ordering? not making distinct yet :)
(: triple pipes?:)
 
return

<result><csv>

<id>{$biosample_id}</id>
<accession>{$accession}</accession>
<primary_id>{$primary_id_data}</primary_id>

<title>{$title}</title>

<dna_source>{$dna_source}</dna_source>
<doi>{$doi}</doi>

<model>{$model_cat}</model>

<package>{$package}</package>
<package_name>{$package_display_name}</package_name>

<status>{$status}</status>
<status_date>{$when}</status_date>

<taxonomy_id>{$taxonomy_id}</taxonomy_id>
<taxonomy_name>{$taxonomy_name}</taxonomy_name>

<paragraph>{$paragraph_cat}</paragraph>

</csv></result>

(: <entrez_label>{$entrez_label}</entrez_label>
<entrez_target>{$entrez_target}</entrez_target>
<entrez_value>{$entrez_value}</entrez_value> :)

(:
<BioSample access="public" publication_date="2009-11-27T16:06:27.253" last_update="2015-01-29T02:26:20.540" submission_date="2009-11-27T16:06:08.140" id="5252" accession="SAMN00005252">
distinct-values(/BioSample/Links/Link[@type="entrez"]/@target)
https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/
https://www.ncbi.nlm.nih.gov/biosample/docs/packages/

can a biosample have multiples of any of the attributes or elements
id	primary_id	accession	title	entrez_label	entrez_target	entrez_value	doi	dna_source	model	package	package_name	taxonomy_id	taxonomy_name	status	status_date	paragraph
:)
