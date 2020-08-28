
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
# columns: biosample|attribute|value
# values:  biosample id| harmonized_name| value of attribute
	gzip -dc downloads/biosample_set.xml.gz | ./util/harmonized-name-eav.pl > $@

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
	
############### WARNING: I RAN THESE ALL NIGHT AND THEY DID NOT COMPLETE
# target/biosample-table.tsv:
# # converts the biosample xml blocks into a tsv
# 	util/biosample-table.pl downloads/biosample_set.xml > $@
#
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
