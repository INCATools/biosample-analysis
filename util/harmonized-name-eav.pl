#!/usr/bin/perl

$writeHeader = 1;

while(<>) {
		if ($writeHeader) {
				print "primary_id\tattribute\tvalue\n";
				$writeHeader = 0;
		}
		
		if (m@<Id .*is_primary="1">(.*)</Id>@) {
				$id = $1;
		}

		if (m@.*harmonized_name="(\S+)".*">(.+)</Attribute>@) {
				print "$id\t$1\t$2\n";
		}
}


