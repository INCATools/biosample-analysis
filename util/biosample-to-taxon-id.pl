#!/usr/bin/perl

$writeHeader = 1;
$header =  "biosample\ttaxonomy_id\n";
%lines = ();

$primaryId = "";
$taxonomyId = "";

while(<>) {
		if ($writeHeader) {
				print $header;
				$writeHeader = 0;
		}

		if (m@<Id .*is_primary="1">(.*)</Id>@) {
				$primaryId = $1;
		}

		if (m@<Organism.*taxonomy_id="(.*?)".*/>@) {
				$taxonomyId = $1;
		}

		if ( $primaryId ne '' and $taxonomyId ne '') {
				$sample = "$primaryId $taxonomyId"; 
				if ( not(exists($lines{$sample})) ) {
						$lines{$sample} = 1;
						print "$primaryId\t$taxonomyId\n";
				}
		}

		if (m@</BioSample>@) {
				$primaryId = "";
				$taxonomyId = "";		
		}
}


