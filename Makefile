.PHONY: target/non-human-samples.tsv .FORCE smalltest biosample_set_basex biosample_table biosample_indices xq_clean

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
	gzip -dc downloads/biosample_set.xml.gz | ./util/hacky-scan.pl > $@

target/attribute-usage.tsv: target/attributes.tsv
	egrep -v '\t(not determined|missing)' $< | cut -f1 | ./util/count-occ.pl | ./util/mysort -r -k1 -n > $@

target/envo-usage.tsv: target/attributes.tsv
	grep '^env_' $< > $@

target/envo-usage-stats.tsv: target/envo-usage.tsv
	cut -f2 $< | ./util/count-occ.pl > $@

# see proposed replacement, with same name, below
#target/harmonized-values-eav.tsv:
## creates a tsv with:
## columns: id|attribute|value
## for attribute tags, only ones with harmonized names are collected
## text values, such as paragagraph and taxonomy name, are also collected as attributes
#	gzip -dc downloads/biosample_set.xml.gz | ./util/harmonized-eav.pl > $@

target/harmonized-values-eav.tsv.gz: target/harmonized-values-eav.tsv
# gzips the target target/harmonized-values-eav.tsv
	gzip -v -c $< > $@

target/harmonized-attributes-only-eav.tsv:
# creates a tsv with ONLY the attributes that have a harmonized name
# e.g., <Attribute attribute_name="estimated_size" harmonized_name="estimated_size">2550000</Attribute>
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

# see proposed replacement, with same name, below
#target/harmonized-table.tsv: target/harmonized-values-eav.tsv
## pivots data in harmonized-values-eav.tsv in a tabular-columnar form
#	./util/harmonized-eav-pivot.pl $< > $@

target/harmonized-table.tsv.gz: target/harmonized-table.tsv
# gzips target/harmonized-table.tsv
	gzip -v -c $< > $@

target/harmonized-table.parquet.gz: target/harmonized-table.tsv
# save target/harmonized-table.tsv as a parquet file
# this makes loading the data easier
	python ./util/save-harmonized-table-to-parquet.py $< $@

## see proposed replacement wiht same name below
#target/harmonized_table.db: target/harmonized-table.tsv
## creates an sqlite3 database of target/harmonized-table.tsv
## NB: this operation takes a few hours to complete
#	python ./util/save-harmonized-table-to-sqlite.py $< $@

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
	./util/count-occ.pl $< | ./util/mysort -r -k1 -n > $@

target/non-human-samples.tsv.gz: .FORCE
# executes the jupyter notebook src/notebooks/build-non-human-samples.ipynb
# in order to create the target/non-human-samples.tsv.gz file
# NB: target/harmonized-table.parquet.gz must exist locally
	jupyter nbconvert --execute --clear-output src/notebooks/build-non-human-samples.ipynb

target/mixs-triad-counts.tsv: target/harmonized_table.db .FORCE
# creates file containing the number of times each mixs triad occurs
# NB: target/harmonized_table.db must exist locally
	util/mixs-triad-counts.py -db $< -out $@

#target/%MIxS_columns.tsv: https://github.com/cmungall/mixs-source/tree/main/src/schema
## This notebook generates two files : MIxS_columns.tsv and Non_MIxS_columns.tsv.
## Highlights the data column names that are MIxS terms and non-MIxS terms
#	jupyter nbconvert --execute --clear-output src/notebooks/MIxS_comparison.ipynb

# ---

# there may already be some values containing pipes, even inside of quotes
# switch to triple pipe ||| to check

delim := '|||'

# somewhat redundant with "target download"
# no phony tasks... all named after targets
# doesn't get EBI samples (which don't go into teh harmonized table anyway?
# unzips biosample_set.xml.gz for loading into basex
# don't know how to load directly from compressed yet
downloads/biosample_set.xml.gz:
	# ~ 1 minute for ~1.3 GB 20210630
	curl -L -s https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz > $@

downloads/biosample_set.xml: downloads/biosample_set.xml.gz
	# ~44 GB unpacked in ~ 1 minute 20210630
	gunzip -c $< > $@

# depends on downloads/biosample_set.xml
# but might not always want to trigger new download (and phony)
# drop if exists first?
biosample_set_basex:
	# another ~ 48 GB in ~ 1 our for the indexed basex database 20210630
	#basex -c "CREATE DB $@ $<"
	basex -c "CREATE DB $@ downloads/biosample_set.xml"
	rm downloads/biosample_set.xml

# suggesting a replacement for Bill's recipe of the same name
# depends on biosample_set_basex recipe, but that's phony
# identifies biosamples with sequential Biosample/@id,
# not with Biosample/@accession or Biosample/Ids/Id[@is_primary=“1”]
# can merge from sqlite table XXX later on
# archive current or previous target/chunks/* instead of just deleting?
# 1 hour
target/harmonized-values-eav.tsv:
	rm -f target/chunks/harmonized-values_*.tsv
	util/get_harmonized-values_chunks.sh $(delim)
	awk '(NR == 1) || (FNR > 1)' target/chunks/harmonized-values_*.tsv > $@
	rm -f target/chunks/harmonized-values_*.tsv

# maybe filter out common unhelpful values?
# cut -f 3  target/chunks/harmonized-values_0_500000.tsv | sort | uniq -c  | sort -n -r > target/harmonized-values_0_500000_counts.txt
# not determined
# missing
# acutally those probably just make up a few percent, like 10,000 out of the 20,000,000 in the first chunk?

# suggesting a replacement for Bill's "legacy" recipe of the same name
# filenames hardcoded for now
target/harmonized-table.tsv: target/harmonized-values-eav.tsv
	python util/harmonized-eav-pivot.py $< $@

#https://unix.stackexchange.com/questions/397806/how-to-pass-multiple-commands-to-sqlite3-in-a-one-liner-shell-command
target/harmonized_table.db: target/harmonized-table.tsv
	sqlite3 $@ "vacuum;"
	sqlite3 $@ -cmd ".mode tabs" ".import $< harmonized_attrib_pivot" ""
	sqlite3 $@ -cmd 'create unique index if not exists id_attrib_idx on harmonized_attrib_pivot ( "id" ) ;' ""

target/non-bsattribute-columns.tsv:
	basex -bdelim=$(delim) xqueries/non-bsattribute-columns.xq >  $@
	sqlite3 target/harmonized_table.db -cmd ".mode tabs" ".import $@ non_bsattribute_columns" ""
	sqlite3 target/harmonized_table.db -cmd 'create unique index if not exists bs_denoters_idx on non_bsattribute_columns ("id", accession_biosample_id, accession)' ""

# 9 minutes
biosample_table:
	sqlite3 target/harmonized_table.db -cmd 'create table biosample as select * from non_bsattribute_columns nbc join harmonized_attrib_pivot hap on nbc."id" = hap."id"' ""
	sqlite3 target/harmonized_table.db "drop table if exists harmonized_attrib_pivot" "drop table if exists  non_bsattribute_columns" ""
	###  DROP COLUMN UNSUPPORTED
	sqlite3 target/harmonized_table.db  'ALTER TABLE biosample RENAME COLUMN "id" TO dropme1' 'ALTER TABLE biosample RENAME COLUMN "id:1" TO dropme2' ''
	sqlite3 target/harmonized_table.db  'ALTER TABLE biosample RENAME COLUMN "legacy_id" TO "id"' ''

target/biosample_packages.xml:
	curl -o target/biosample_packages.xml https://www.ncbi.nlm.nih.gov/biosample/docs/packages/?format=xml

biosample_indices:
	sqlite3 target/harmonized_table.db < queries/ht_indicies.sql

xq_clean:
	rm -rf downloads/biosample_set.xml downloads/biosample_set.xml
	rm -rf target/harmonized-values-eav.tsv target/harmonized-table.tsv target/non-bsattribute-columns.tsv
	rm -rf target/chunks/*
	rm -rf target/harmonized_table.db


# typical order of make steps
# xq_clean
# downloads/biosample_set.xml <- downloads/biosample_set.xml
# biosample_set_basex
# target/harmonized_table.db <- target/harmonized-table.tsv <- target/harmonized-values-eav.tsv
# target/non-bsattribute-columns.tsv
# biosample_table
### compress and publish before indexing?
# biosample_indices

# TODO dump the SQLite database so that other attifacts like Parquet can be created
# target/harmonized-table.parquet.gz: target/harmonized-table.tsv
# the target/harmonized-table.tsv that i've created in this xquery approach onyl contains "attributes"
# Bill's approach contains the

### ---

# useful but unrealted
# target/biosample_packages.xml

## awkward attempt to make a subset of the biosample data
#downloads/biosample_set_destructive.xml: downloads/biosample_set.xml
#	# calculate maxent from some fraction of the whole dataset?
#	# either way, this requires that the whole dataset is already loaded ito basex
#	# and that biosample_set_basex_keep does not exist yet
#	# should also rename existing target/harmonized*
#	# ditto target/chunks/*
#	#basex -c "list"
#	basex -bmaxent=2000000 xqueries/get_first_n_biosamples.xq > $@
#	basex -c "alter db biosample_set_basex biosample_set_basex_keep"
#	#if [ -f downloads/biosample_set.xml ]; then ...
#	mv $< $<.keep
#	#; fi
#	cp $@ $<
