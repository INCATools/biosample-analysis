#!/usr/bin/perl
use Text::Trim 'trim';

# print header of document
#$header =  "biosample\ttaxonomy_id\ttaxonomy_name\tattribute\tharmonized\tvalue\n";
$header =  "primary_id\tsra_id\tsample_name\towner_abbr\towner_name\ttaxonomy_id\ttaxonomy_name\torganism_name\tattribute\tharmonized\tattribute_value\tstatus\tstatus_date\tmodel\tpackage\tpackage_name\ttitle\taccession\tsubmission_date\tlast_update\tpublication_date\tdna_source\tentrez_target\tentrez_label\tentrez_value\tparagraph\n";
print $header;

@attributes = ();

# default values
$primaryId = "";
$sraId = "";
$sampleName = "";
$ownerAbbr = "";
$ownerName = "";
$taxonomyId = "";
$taxonomyName = "";
$organismName = "";
$attributeName = "";
$harmonizedName = "";
$status = "";
$statusDate = "";
$model = "";
$package = "";
$packageName = "";
$title = "";
$accession = "";
$submissionDate = "";
$lastUpdate = "";
$publicationDate = "";
$dnaSource = "";
$entrezTarget = "";
$entrezLabel = "";
$entrezValue = "";
$paragraph = "";

while(<>) {
		trim; # remove leading/trailing spaces
		# print "$_\n";

		if (m@<BioSample.*accession="(.+?)".*>$@) {
				$accession = $1;
		}

		if (m@<BioSample.*submission_date="(.+?)".*>$@) {
				$submissionDate = $1;
		}
		
		if (m@<BioSample.*last_update="(.+?)".*>$@) {
				$lastUpdate = $1;
		}

		if (m@<BioSample.*publication_date="(.+?)".*>$@) {
				$publicationDate = $1;
		}

		if (m@^<Id .*is_primary="1">(.+?)</Id>$@) {
				$primaryId = $1;
		}

		if (m@^<Id .*db_label="Sample name">(.+?)</Id>$@) { # information seems uneeded
				$sampleName = $1;
		}

		if (m@^<Id db="SRA">(.+?)</Id>$@) { # information seems uneeded
				$sraId = $1;
    }
		
		if (m@^<Organism.*taxonomy_id="(.+?)".*>?@) {
				$taxonomyId = $1;
		}

		if (m@^<Organism.*taxonomy_name="(.+?)".*>?@) {
				$taxonomyName = $1;
		}

		if (m@^<OrganismName>(.+?)</OrganismName>$@) {
				$organismName = $1;
		}

		if (m@^<Name abbreviation="(.+?)".*>?@) {
				$ownerAbbr = $1;
		}

		if (m@^<Name.*>(.+?)</Name>$@) {
				$ownerName = $1;
		}
		
		if (m@<Attribute attribute_name="(.+?)".*>?@) {
				$attributeName = $1;
		} else {
				$attributeName = "";
		}

		if (m@<Attribute.*harmonized_name="(.+?)".*>?@) {
				$harmonizedName = $1;
		} else {
				$harmonizedName = "";
		}

		if (m@<Model>(.+?)</Model>$@) {
				if (length($model) > 0) {
						$model = "$model, $1";
				} else {
						$model = $1;
				}
		}

		if (m@<Package>(.+?)</Package>$@) {
				$package = $1;
		}

		if (m@<Package .*display_name="(.+?)".*>?@) {
				$packageName = $1;
		}

		if (m@<Title>(.+?)</Title>$@) {
				$title = $1;
		}
		
		if (m@<Paragraph>(.+?)</Paragraph>$@) {
				if (length($paragraph) > 0) {
						$paragraph = "$paragraph $1";
				} else {
						$paragraph = $1;
				}
		}
		
		# we only to output rows with values (i.e. (.+)); push onto attributes array
		if (m@^<Attribute .*?>(.+?)</Attribute>$@) {
				push @attributes, "$attributeName\t$harmonizedName\t$1";

		}

		if (m@<Status .*status="(.+?)".*>?@) {
				$status = $1;
		}

		if (m@<Status .*when="(.+?)".*>?@) {
				$statusDate = $1;
		}

		if (m@<Link type="url" label="DNA Source">(.+?)</Link>$@) {
				$dnaSource = $1;
		}

		if (m@<Link type="entrez".*target="(.+?)".*>?@) {
				$entrezTarget = $1;
		}

		if (m@<Link type="entrez".*label="(.+?)".*>?@) {
				$entrezLabel = $1;
		}

		if (m@<Link type="entrez".*>(.+?)</Link>$@) {
				$entrezValue = $1;
		}

		if (m@^</BioSample>$@) { # we've reached the end of a biosample block

				# unwind the attributes array
				for my $attr (@attributes) {
						print "$primaryId\t$sraId\t$sampleName\t$ownerAbbr\t$ownerName\t$taxonomyId\t$taxonomyName\t$organismName\t$attr\t$status\t$statusDate\t$model\t$package\t$packageName\t$title\t$accession\t$submissionDate\t$lastUpdate\t$publicationDate\t$dnaSource\t$entrezTarget\t$entrezLabel\t$entrezValue\t$paragraph\n";
				}

				# reset default values
				$primaryId = "";
				$sraId = "";
				$sampleName = "";
				$ownerAbbr = "";
				$ownerName = "";
				$taxonomyId = "";
				$taxonomyName = "";
				$organismName = "";
				$attributeName = "";
				$harmonizedName = "";
				$status = "";
				$statusDate = "";
				$model = "";
				$package = "";
				$packageName = "";
				$title = "";
				$accession = "";
				$submissionDate = "";
				$lastUpdate = "";
				$publicationDate = "";
				$dnaSource = "";
				$entrezTarget = "";
				$entrezLabel = "";
				$entrezValue = "";
				$paragraph = "";
		}
}


