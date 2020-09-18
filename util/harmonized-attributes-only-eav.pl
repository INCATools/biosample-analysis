#!/usr/bin/perl
use Text::Trim 'trim';
use utf8;
binmode STDOUT, ":utf8";

my $accession = "";
my $attrName = "";
my $value = "";

print "accession\tattribute\tvalue\n"; # print the header

while(<>) {
		trim;

		if (m@^<BioSample .*accession="(.+?)"@) { # collect accession number from BioSample tag
				$accession = $1;
				#print $accession;
		}


		if (m@.*harmonized_name="(.+?)".*>(.+)</Attribute>@) {
				# remove extra spaces and new lines from attribute names and values
				$attrName = trim($1);
				$attrName =~ s/\R//g; # \R is meta for \r\n and \n
				
				$value = trim($2);
				$value =~ s/\R//g; # \R is meta for \r\n and \n
				
				if ($value ne '') { print "$accession\t$1\t$2\n"; }		
		}
}

