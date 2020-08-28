#!/usr/bin/perl
use Text::Trim 'trim';
my $firstIter = 1;

print "[\n"; # beginning of json list


while(<>) {
		trim; # trim spaces

		if (m@^<BioSample\s{1}?@) { # start of json object
				if ($firstIter == 1) {
						print "  {\n";
						$firstIter = 0;
				} else {
						print " ,{\n";
				}
		}

		if (m@^<Id .*is_primary="1">(.+?)</Id>$@) {
				print "    \"primary_id\": \"$1\"\n";
		}

		if (m@^<Id db="SRA">(.+?)</Id>$@) { # information seems uneeded
				print "    , \"sra_id\": \"$1\"\n";
    }

		
		if (m@^<Name abbreviation="(.+?)".*>?@) {
				print "    , \"owner_abbr\": \"$1\"\n";
		}

		if (m@^<Organism.*taxonomy_id="(.+?)".*>?@) {
				print "    , \"taxonomy_id\": \"$1\"\n";
		}

		# we only to output rows with values (i.e. (.+)); set hash value
		if (m@^<Attribute attribute_name="(.+?)".*>(.+?)</Attribute>$@) {
				print "    , \"$1\": \"$2\"\n";
		}

		if (m@^</BioSample>$@) { # end of json object
				print "  }\n";
		}
}

print "]\n" # end of json list
