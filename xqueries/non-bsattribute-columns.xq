declare option output:method "csv";
declare option output:csv "header=yes, separator=tab";

declare variable $delim external;

(: let $delim := "***" :)

(: externally check if any biosample ids are repeated
that would mean that multidata hadn't been accounted for:)

(: do we want special handling of description paragraphs that start with "keywords":)

for $bs in doc(
  'biosample_set_basex'
)/BioSampleSet/BioSample


let $accession :=  fn:normalize-space(
  string-join(
    data(
      $bs/@accession
    ),$delim
  )
)
let $biosample_id := fn:normalize-space(
  string-join(
    data(
      $bs/@id
    ),$delim
  )
)
let $dna_source := fn:normalize-space(
  string-join(
    data(
      $bs/Links/Link[@type="url" and @label="DNA Source"]
    ),$delim
  )
)
let $doi := fn:normalize-space(
  string-join(
    data(
      $bs/Links/Link[@label="DOI"]
    ),$delim
  )
)

let $entrez_label :=fn:normalize-space(
  string-join(
    data(
      $bs/Links/Link[@type="entrez"]/@label
    ),$delim
  )
)
let $entrez_target :=fn:normalize-space(
  string-join(
    distinct-values(
      $bs/Links/Link[@type="entrez"]/@target
    ),$delim
  )
)
let $entrez_value := fn:normalize-space(
  string-join(
    data(
      $bs/Links/Link[@type="entrez"]
    ),$delim
  )
)

let $model_cat := fn:normalize-space(
  string-join(
    data(
      $bs/Models/Model
    ),$delim
  )
)
let $package := fn:normalize-space(
  string-join(
    data(
      $bs/Package
    ),$delim
  )
)
let $package_display_name := fn:normalize-space(
  string-join(
    data(
      $bs/Package/@display_name
    ),$delim
  )
)
let $paragraph_cat := fn:normalize-space(
  string-join(
    data(
      $bs/Description/Comment/Paragraph
    ),$delim
  )
)

let $primary_id_data := fn:normalize-space(
  string-join(
    data(
      $bs/Ids/Id[@is_primary="1"]
    ),$delim
  )
)
let $legacy_id := concat(
  "BIOSAMPLE:",data(
    $bs/Ids/Id[@is_primary = "1"]
  )
)

let $status := fn:normalize-space(
  string-join(
    data(
      $bs/Status/@status
    ),$delim
  )
)
let $taxonomy_id := fn:normalize-space(
  string-join(
    data(
      $bs/Description/Organism/@taxonomy_id
    ),$delim
  )
)
let $taxonomy_name := fn:normalize-space(
  string-join(
    data(
      $bs/Description/Organism/@taxonomy_name
    ),$delim
  )
)
let $title := fn:normalize-space(
  string-join(
    data(
      $bs/Description/Title
    ),$delim
  )
)
let $when := fn:normalize-space(
  string-join(
    data(
      $bs/Status/@when
    ),$delim
  )
)

let $xref := fn:normalize-space(
  string-join(
    $bs/Ids/Id/concat(
      @db,':',.
    ),$delim
  )
)

let $entrez_link := $bs/Links/Link[@type="entrez"]

let $entrez_links := fn:normalize-space(
  string-join(
    $entrez_link/concat(
      @target,':',@label,":",.
    ),$delim
  )
)

let $accession := data(
  $bs/@accession
)

return

<result><csv>
<id>{$biosample_id}</id>
<legacy_id>{$legacy_id}</legacy_id>
<accession_biosample_id>{
  $biosample_id
}</accession_biosample_id>
<accession>{
  $accession
}</accession>
<xref>{
  $xref
}</xref>

<entrez_links>
{
  $entrez_links
}
</entrez_links>

<title>{
  $title
}</title>

<dna_source>{
  $dna_source
}</dna_source>
<doi>{
  $doi
}</doi>

<model>{
  $model_cat
}</model>

<package>{
  $package
}</package>
<package_name>{
  $package_display_name
}</package_name>

<status>{
  $status
}</status>
<status_date>{
  $when
}</status_date>

<taxonomy_id>{
  $taxonomy_id
}</taxonomy_id>
<taxonomy_name>{
  $taxonomy_name
}</taxonomy_name>

<paragraph>{
  $paragraph_cat
}</paragraph>

</csv></result>


(:
<accession>{
  $accession
}</accession>
<primary_id>{
  $primary_id_data
}</primary_id>
:)


(: <entrez_label>{
  $entrez_label
}</entrez_label>
<entrez_target>{
  $entrez_target
}</entrez_target>
<entrez_value>{
  $entrez_value
}</entrez_value> :)

(:
<BioSample access="public" publication_date="2009-11-27T16:06:27.253" last_update="2015-01-29T02:26:20.540" submission_date="2009-11-27T16:06:08.140" id="5252" accession="SAMN00005252">
distinct-values(
  /BioSample/Links/Link[@type="entrez"]/@target
)
https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/
https://www.ncbi.nlm.nih.gov/biosample/docs/packages/

can a biosample have multiples of any of the attributes or elements
id  primary_id  accession title entrez_label  entrez_target entrez_value  doi dna_source  model package package_name  taxonomy_id taxonomy_name status  status_date paragraph
:)

(: let $access :=  fn:normalize-space(
  data(
    $bs/@access
  )
) :)
(: let $curation_date := fn:normalize-space(
  $bs/Curation/@curation_date
)
(: let $curation_status := fn:normalize-space(
  $bs/Curation/@curation_status
) :) :)
(: let $is_reference :=  fn:normalize-space(
  data(
    $bs/@is_reference
  )
) :)
(: let $last_update :=  fn:normalize-space(
  data(
    $bs/@last_update
  )
)
(: let $model_version_cat := fn:normalize-space(
  string-join(
    data(
      $bs/Models/Model/@version
    ),"|"
  )
) :)
(: let $organism_name_cat := fn:normalize-space(
  string-join(
    data(
      $bs/Description/Organism/OrganismName
    ),"|"
  )
) :)
(: let $publication_date :=  fn:normalize-space(
  data(
    $bs/@publication_date
  )
) :) :)
(: let $submission_date :=  fn:normalize-space(
  data(
    $bs/@submission_date
  )
) :)


(: let $primary_id_element := $bs/Ids/Id[@is_primary="1"]
let $primary_id_data := fn:normalize-space(
  data(
    $primary_id_element
  )
) :)


