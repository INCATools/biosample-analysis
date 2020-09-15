
downloads/biosample_set.xml.gz:
	curl -L -s https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz > $@

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
# columns: accession|attribute|value
# for attribute tags, only ones with harmonized names are collected
# text values, such as paragagraph and taxonomy name, are also collected as attributes
#	gzip -dc downloads/biosample_set.xml.gz | ./util/harmonized-name-eav.pl > $@
	gzip -dc downloads/biosample_set.xml.gz | ./util/harmonized-eav.pl > $@

target/harmonized-values-eav.tsv.gz: target/harmonized-values-eav.tsv
# gzips the target target/harmonized-values-eav.tsv
	gzip -v -c $< > $@

target/biosample-attribute-value.tsv:
# creates a tsv with columns: primary_id|sra_id|attribute|harmonized|value
	gzip -dc downloads/biosample_set.xml.gz | ./util/biosample-attribute-value.pl > $@

target/biosample-attribute-value.tsv.gz: target/biosample-attribute-value.tsv
# gzips target/biosample-attribute-value.tsv
	gzip -v -c $< > $@ 

target/biosample-to-json.json:
# converts the primary_id, sra_id, and attributes to json structure
	gzip -dc downloads/biosample_set.xml.gz | ./util/biosample-to-json.pl > $@

target/biosample-to-json.json.gz: target/biosample-to-json.json
# gzips target/biosample-to-json.json
	gzip -v -c $< > $@

target/biosample-attribute-value.ttl: target/biosample-attribute-value.tsv.gz
# convert biosample-attribute-value to rdf (turtle)
# the output triples are of form <:subj> <:pred> <:value>; so it is also in n3 format
# each attribute also has an rdfs label and a harmonized predicate to link the harmonized name
	gzip -dc $< |  ./util/biosample-eav-to-rdf.pl > $@

target/biosample-attribute-value.ttl.gz: target/biosample-attribute-value.ttl
# gzips target/biosample-attribute-value.ttl
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
