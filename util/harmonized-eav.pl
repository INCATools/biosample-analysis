#!/usr/bin/perl
use Text::Trim 'trim';
use utf8;
binmode STDOUT, ":utf8";

my $accession = "";
# my $biosampleId = "";
# my $primaryId = "";
my $dbIds = "";
my %dbMap = ();
my $value = "";
my $attrName = "";
my %attributes = ();
my $paragraph = "";
my $title = "";

print "id\tattribute\tvalue\n"; # write header

while(<>) {
		trim;
		
		if (m@^</BioSample>$@) { # we've reached the end of a biosample block
				$attributes{'xref'} = collectDbIds(); # build pipe delimited list of db ids
				printAttributes (); # print collected attributes
				resetValues(); # clear values
		}

		if (m@^<BioSample .*accession="(.+?)"@) { # collect accession number from BioSample tag
				$accession = "BIOSAMPLE:$1";
				#print $accession;
		}

		if (m@^<BioSample .*id="(.+?)"@) { # collect biosample id from BioSample tag
				#$biosampleId = $1;
				$attributes{'accession_biosample_id'} = $1;
		}
		
		if (m@^<Id .*db="(.+?)".*>(.+)</Id>$@) { # db name and associated id
				$dbMap{uc $1} = $2; # upper case the db name
				# if (m@^<Id .*is_primary="1">@) { $primaryId = $1; } # not worrying about primary_id for now ...
		}

		if (m@^<Organism.*taxonomy_id="(.+?)".*>?@) { # collect taxonomy id
				$attributes{'taxonomy_id'} = $1;
		}

		if (m@^<Organism.*taxonomy_name="(.+?)".*>?@) { # collect taxonomy name
				$attributes{'taxonomy_name'} = $1;
		}

		if (m@^<Title.*>(.+)</Title>$@) { # collect title
				$title = trim($1);
				$title =~ s/\R//g; # \R is meta for \r\n and \n
				
				if ($title ne '') { $attributes{'title'} = $title; }
		}
		
		if (m@^<Paragraph.*>(.+)</Paragraph>$@) { # collect paragraph tag info
				$paragraph = trim($1);
				$paragraph =~ s/\R//g; # \R is meta for \r\n and \n
				
				if ($paragraph ne '') {
						if (length($attributes{'paragraph'}) > 0) {
								$attributes{'paragraph'} = "$attributes{'paragraph'} $paragraph";
						} else {
								$attributes{'paragraph'} = $paragraph;
						}
				}
		}

		if (m@^<Model.*>(.+?)</Model>$@) { # collect model info
				if (length($attributes{'model'}) > 0) {
						$attributes{'model'} = "$attributes{'model'}, $1";
				} else {
						$attributes{'model'} = "$1";
				}
		}

		if (m@^<Package.*>(.+?)</Package>$@) { # collect package info
				$attributes{'package'} = "$1";
		}

		if (m@<Package .*display_name="(.+?)".*>?@) { # collect package name
				$attributes{'package_name'} = "$1";
		}

		if (m@^<Attribute .*harmonized_name="(.+?)".*">(.+)</Attribute>@) { # collect attribute tag info
				$attrName = trim($1);
				$attrName =~ s/\R//g; # \R is meta for \r\n and \n
				
				$value = trim($2);
				$value =~ s/\R//g; # \R is meta for \r\n and \n
				if ($value ne '') {$attributes{$attrName} = $value;}
		}

		if (m@^<Status .*status="(.+?)".*>$@) { # collect living status of sample
				$attributes{'status'} = $1;
		}

		if (m@^<Status .*when="(.+?)".*>$@) { # collect status daate
				$attributes{'status_date'} = $1;
		}

		if (m@<Link type="url" label="DNA Source">(.+)</Link>$@) { # collect DNA source
				$attributes{'dna_source'} = $1;
		}

		if (m@<Link type="entrez".*target="(.+?)".*>?@) { # collect entrez target
				$attributes{'entrez_target'} = $1;
		}

		if (m@<Link type="entrez".*label="(.+?)".*>?@) { # collect entrez  label
				$attributes{'entrez_label'} = $1;
		}

		if (m@<Link type="entrez".*>(.+)</Link>$@) { # collect entrez value
				$attributes{'entrez_value'} = $1;
		}

}

### subroutines ###

sub printAttributes { # print collected attributes
		while (($key, $val) = each(%attributes)) {
				print "$accession\t$key\t$val\n";
		}
}


sub collectDbIds {
		# my $i = 0;
		# while (($key, $val) = each(%dbMap)) { #  build pipe delimited list of db ids
		# 		if ($i > 0) {
		# 				$dbIds = "$dbIds|$key:$val";
		# 		} else {
		# 				$dbIds = "$key:$val";
		# 		}
		# 		$i++;
		# }
		$dbIds = join("|", map { "$_:$dbMap{$_}" } keys %dbMap); # e.g., BioSample:SAMN0001|SRS:100011|...
		return $dbIds;
}


sub resetValues { # clear values
		$accession = "";
		#$biosampleId = "";
		$dbIds = "";
		$value = "";
		%dbMap = ();
		%attributes = ();
		$paragraph = "";
		$title = "";
}


