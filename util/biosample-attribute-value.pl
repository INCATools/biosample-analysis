#!/usr/bin/perl

$writeHeader = 1;
$primaryId = "";

while(<>) {
		if ($writeHeader) {
				print "biosample\tattribute\tvalue\n";
				$writeHeader = 0;
		}
		
		if (m@<Id .*is_primary="1">(.+)</Id>@) {
				$primaryId = $1;
		}

		if (m@.*attribute_name="(.+?)".*?>(.+?)</Attribute>@ and $primaryId ne '') {
				#$attribute = $1;
				#$value = $2;
				print "$primaryId\t$1\t$2\n";
		}

		# if ( $primaryId ne '' and $attribute ne '' and $value ne '' ) {
		# 		print "$primaryId\t$attribute\t$value\n";
		# }
		
		if (m@</BioSample>@) {
				$primaryId = "";
		}
}
