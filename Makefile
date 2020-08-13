
target download:
	curl -L -s https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz > downloads/biosample_set.xml.gz
	curl -L -s https://raw.githubusercontent.com/kbaseapps/kb_cmash/master/lib/kb_cmash/utils/data/ebi_samples_metadata_with_studies_final_with_cols.csv > downloads/ebi_samples_metadata_with_studies_final_with_cols.csv

target/attributes.tsv:
	gzip -dc downloads/biosample_set.xml.gz  | ./util/hacky-scan.pl > $@

target/attribute-usage.tsv: target/attributes.tsv
	egrep -v '\t(not determined|missing)' $<  | cut -f1 | ./util/count-occ.pl | ./util/mysort -r -k1 -n > $@

target/envo-usage.tsv: target/attributes.tsv
	grep '^env_' $< > $@
target/envo-usage-stats.tsv: target/envo-usage.tsv
	cut -f2 $< | ./util/count-occ.pl  > $@


target/occurrences-%.tsv: target/attributes.tsv
	egrep '^$*\t' $< | cut -f2 > $@
.PRECIOUS: target/occurrences-%.tsv
target/distinct-%.tsv: target/occurrences-%.tsv
	./util/count-occ.pl $< | ./util/mysort -r -k1 -n  > $@

