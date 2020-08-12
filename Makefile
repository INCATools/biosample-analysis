
downloads/biosample_set.xml.gz:
	curl -L -s https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz > $@

target/attributes.tsv:
	gzip -dc downloads/biosample_set.xml.gz  | ./util/hacky-scan.pl > $@

target/attribute-usage.tsv: target/attributes.tsv
	grep -v 'not determined' $<  | cut -f1 | ./util/count-occ.pl

target/envo-usage.tsv: target/attributes.tsv
	grep '^env_' $< > $@
target/occurrences-%.tsv: target/attributes.tsv
	egrep '^$*\t' $< | cut -f2 > $@
target/distinct-%.tsv: target/occurrences-%.tsv
	./util/count-occ.pl $< > $@
