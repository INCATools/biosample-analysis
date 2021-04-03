
.PHONY: target/non-human-samples.tsv .FORCE

target download:
	curl -L -s https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz > downloads/biosample_set.xml.gz
	curl -L -s https://raw.githubusercontent.com/kbaseapps/kb_cmash/master/lib/kb_cmash/utils/data/ebi_samples_metadata_with_studies_final_with_cols.csv > downloads/ebi_samples_metadata_with_studies_final_with_cols.csv

downloads/emp.tsv:
	curl -L -s ftp://ftp.microbio.me/emp/release1/mapping_files/emp_qiime_mapping_release1.tsv > $@

downloads/emp_studies.csv:
	curl -L -s 'https://zenodo.org/record/890000/files/emp_studies.csv?download=1' > $@

target/emp_studies.tsv: downloads/emp_studies.csv
	mlr --csv --otsv cat $< > $@


target/attributes.tsv:
	gzip -dc downloads/biosample_set.xml.gz  | ./util/hacky-scan.pl > $@

target/attribute-usage.tsv: target/attributes.tsv
	egrep -v '\t(not determined|missing)' $<  | cut -f1 | ./util/count-occ.pl | ./util/mysort -r -k1 -n > $@

target/envo-usage.tsv: target/attributes.tsv
	grep '^env_' $< > $@

target/envo-usage-stats.tsv: target/envo-usage.tsv
	cut -f2 $< | ./util/count-occ.pl  > $@

target/harmonized-values-eav.tsv:
# creates a tsv with:
# columns: id|attribute|value
# for attribute tags, only ones with harmonized names are collected
# text values, such as paragagraph and taxonomy name, are also collected as attributes
	gzip -dc downloads/biosample_set.xml.gz | ./util/harmonized-eav.pl > $@

target/harmonized-values-eav.tsv.gz: target/harmonized-values-eav.tsv
# gzips the target target/harmonized-values-eav.tsv
	gzip -v -c $< > $@

target/harmonized-attributes-only-eav.tsv:
# creates a tsv with ONLY the attributes that have a harmonized name
#   e.g., <Attribute attribute_name="estimated_size" harmonized_name="estimated_size">2550000</Attribute>
# columns: accession|attribute|value
	gzip -dc downloads/biosample_set.xml.gz | ./util/harmonized-attributes-only-eav.pl > $@

target/harmonized-attributes-only-eav.tsv.gz: target/harmonized-attributes-only-eav.tsv
# gzips the target target/harmonized-attributes-only-eav.tsvj
	gzip -v -c $< > $@

target/harmonized-attribute-value.ttl: target/harmonized-values-eav.tsv.gz
# convert harmonized-values-eav.tsv to rdf (turtle)
# the output triples are of form <:subj> <:pred> <:value>; so it is also in n3 format
# each attribute also has an rdfs label
	gzip -dc $< | ./util/harmonized-eav-to-rdf.pl > $@

target/harmonized-attribute-value.ttl.gz: target/harmonized-attribute-value.ttl
# gzips target/harmonized-attribute-value.ttl
	gzip -v -c $< > $@

target/harmonized-table.tsv: target/harmonized-values-eav.tsv
# pivots data in harmonized-values-eav.tsv in a tabular-columnar form
	./util/harmonized-eav-pivot.pl $< > $@

target/harmonized-table.tsv.gz: target/harmonized-table.tsv
# gzips target/harmonized-table.tsv
	gzip -v -c $< > $@

target/harmonized-table.parquet.gz: target/harmonized-table.tsv
# save target/harmonized-table.tsv as a parquet file
# this makes loading the data easier
	python ./util/save-harmonized-table-to-parquet.py $< $@

target/harmonized_table.db: target/harmonized-table.tsv
# creates an sqlite3 database of target/harmonized-table.tsv
# NB: this operation takes a few hours to complete
	python ./util/save-harmonized-table-to-sqlite.py $< $@

target/harmonized_table.db.gz: target/harmonized_table.db
# gzips target/harmonized_table.db.gz
	gzip -v -c $< > $@

target/biosample-table.tsv: target/biosample-attribute-value.tsv
# converts target/biosample-attribute-value.tsv (EAV format) into a tabular column format
	util/biosample-eav-pivot.pl $< > $@

############### WARNING: I RAN THIS ALL NIGHT AND IT DID NOT COMPLETE
# target/biosample-table.tsv.gz: target/biosample-table.tsv
# # gzips target/biosample-table.tsv
# 	gzip -v -c $< > $@

# target/biosample-table-reduced.tsv:	
# # similar to biosample-table.pl, but only puts attribute values in the table
# 	util/biosample-table-reduced.pl downloads/biosample_set.xml > $@
##################

target/attribute-to-harmonized-lookup.tsv:
# create a lookup table matching the attribute names to harmonized names
	gzip -dc downloads/biosample_set.xml.gz | ./util/attribute-to-harmonized-lookup.pl > $@

target/taxon-id-to-name-lookup.tsv:
# create a lookup table matching the taxonomy ids to taxonomy names
	gzip -dc downloads/biosample_set.xml.gz | ./util/taxon-id-to-name-lookup.pl > $@

target/biosample-to-taxon-id.tsv:
# create a lookup table matching the biosample to its taxonomy id
	gzip -dc downloads/biosample_set.xml.gz | ./util/biosample-to-taxon-id.pl > $@

target/occurrences-%.tsv: target/attributes.tsv
	egrep '^$*\t' $< | cut -f2 > $@
.PRECIOUS: target/occurrences-%.tsv
target/distinct-%.tsv: target/occurrences-%.tsv
	./util/count-occ.pl $< | ./util/mysort -r -k1 -n  > $@

target/non-human-samples.tsv.gz: .FORCE
# executes the jupyter notebook src/notebooks/build-non-human-samples.ipynb
# in order to create the target/non-human-samples.tsv.gz file
# NB: target/harmonized-table.parquet.gz must exist locally
	jupyter nbconvert --execute --clear-output src/notebooks/build-non-human-samples.ipynb

target/mixs-triad-counts.tsv: target/harmonized_table.db .FORCE
# creates file containing the number of times each mixs triad occurs
# NB: target/harmonized_table.db must exist locally
	util/mixs-triad-counts.py -db $< -out $@

target/nmdc-biosample-one-hot.tsv: downloads/nmdc-gold-path-ner/runner/runNER_Output.tsv
# create a one-hot encoded representation of the named entities found by runNER
	util/one-hot-encode-nmdc-biosample-net.py -i $< -o $@

target/nmdc-biosample-one-hot.tsv.gz: target/nmdc-biosample-one-hot.tsv
# gzip target/nmdc-biosample-one-hot.tsv
	gzip -v -c $< > $@
