#!/usr/bin/perl

$writeHeader = 1;
$header =  "taxonomy_id\ttaxonomy_name\n";
%lines = ();

while(<>) {
		if ($writeHeader) {
				print $header;
				$writeHeader = 0;
		}
		
		if (m@<Organism.*taxonomy_id="(.+?)".*taxonomy_name="(.+?)".*?/>@) {
				$taxon = "$1 $2";
				if ( not(exists($lines{$taxon})) ) {
						$lines{$taxon} = 1;
						print "$1\t$2\n";
				}
		}
}


