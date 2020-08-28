#!/usr/bin/perl
use Text::Trim 'trim';

my $primaryId = "";
my $sraId = "";
my $header = "primary_id\tsra_id\tattribute\tharmonized\tvalue\n";

print $header;
while(<>) {
		trim;
		if (m@^<Id .*is_primary="1">(.+)</Id>$@) {
				$primaryId = $1;
		}

		if (m@^<Id db="SRA">(.+?)</Id>$@) { # information seems uneeded
				$sraId = $1;
    }

		if ( m@^<Attribute attribute_name="(.+?)"\s*(harmonized_name="(.+?)")?.*>(.+?)</Attribute>$@) {
				print "$primaryId\t$sraId\t$1\t$3\t$4\n";
		}
		
		if (m@^</BioSample>$@) {
				# reset values
				$primaryId = "";
				$sraId = "";
		}
}
