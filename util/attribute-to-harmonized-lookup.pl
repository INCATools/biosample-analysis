#!/usr/bin/perl

$writeHeader = 1;
$header =  "attribute\tharmonized\n";
%lines = ();
# $attribute = "";

while(<>) {
		if ($writeHeader) {
				print $header;
				$writeHeader = 0;
		}
		
		if (m@.*attribute_name="(.+?)".*harmonized_name="(.+?)".*?>@) {
				$attribute = "$1 $2";
				if ( not(exists($lines{$attribute})) ) {
						$lines{$attribute} = 1;
						print "$1\t$2\n";
				}
		}
}


