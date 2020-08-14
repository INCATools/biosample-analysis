#!/usr/bin/perl

$writeHeader = 1;
$header =  "biosample\ttaxonomy_id\ttaxonomy_name\tattribute\tharmonized\tvalue\n";

$primaryId = "";
# $sampleName = ""; # don't need this now
# $sraId = ""; # don't need this now
$taxonomyId = "";
$taxonomyName = "";
$attributeName = "";
$harmonizedName = "";

while(<>) {
		if ($writeHeader) {
				print $header;
				$writeHeader = 0;
		}

		if (m@<Id .*is_primary="1">(.*)</Id>@) {
				$primaryId = $1;
		}

		# if (m@<Id .*db_label="Sample name">(.*)</Id>@) { # information seems uneeded
		# 		$sampleName = $1;
		# }

		# if (m@<Id db="SRA">(.*)</Id>@) { # information seems uneeded
		# 		$sraId = $1;
    # }
		
		if (m@<Organism.*taxonomy_id="(.*?)".*/>@) {
				$taxonomyId = $1;
		}

		if (m@<Organism.*taxonomy_name="(.*?)".*/>@) {
				$taxonomyName = $1;
		}


		if (m@.*attribute_name="(.*?)".*?>@) {
				$attributeName = $1;
		} else {
				$attributeName = "";
		}

		if (m@.*harmonized_name="(.*?)".*?>@) {
				$harmonizedName = $1;
		} else {
				$harmonizedName = "";
		}

		# we only to output rows with values (i.e. (.+))
		if (m@<Attribute .*?>(.+)</Attribute>@) {
				print "$primaryId\t$taxonomyId\t$taxonomyName\t$attributeName\t$harmonizedName\t$1\n";
		}

		
		if (m@</BioSample>@) {
				$primaryId = "";
				# $sampleName = "";
				# $sraId = "";
				$taxonomyId = "";
				$taxonomyName = "";
				$attributeName = "";
				$harmonizedName = "";
		}
}


