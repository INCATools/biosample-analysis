let $sep := '|'
for $bs in doc('biosample_set')/BioSampleSet/BioSample
(: mutiple Id elements, potentially with db, is_primary and db_label attributes :) 
let $id := $bs/Ids/Id[@is_primary="1"]
(: description also has Comment/Paragraph elements :)
let $dt := $bs/Description/Title
let $ti := $bs/Description/Organism/@taxonomy_id
let $mm := $bs/Models/Model
  
return string-join(
       (
         data($id),
         data($dt),
         data($mm),
         data($ti)
       ),
       "|")
       
(: return
  concat(
    escape-html-uri(
      string-join(
       (
         data($id),
         data($dt),
         data($mm)
       ),
       "|"
      )
    ),
    codepoints-to-string(10)
  ) :)
  
(: declare option output:method "csv";
declare option output:csv "header=yes, separator=semicolon"; :)

(: return :) 
(: <csv>
<record> :)
(: </record>
</csv> :)



