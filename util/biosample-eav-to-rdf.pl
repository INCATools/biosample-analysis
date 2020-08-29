#!/usr/bin/perl
use String::Util 'trim';
use URI::Escape;

my $base = "http://inca-biosample.org";
my $subj = "";
my $prevId = "";
my $value = "";
my $attr = "";
my $attrName = "";
my @preds = ();
my @data = ();
my %attributes = ();
my $harmName = "";
my %harmonized_names = ();

my $line = <>; # skip header
while ($line = <>) {
		@data = split(/\t/, $line);
		$subj = "<$base#$data[0]>"; # build subject of triple

		
		if ($prevId ne $data[0]) { # only print the ids once
				print "$subj <$base#primary_id> \"$data[0]\"^^xsd:string .\n"; # primary_id 
				print "$subj <$base#sra_id> \"$data[1]\"^^xsd:string .\n";     # sra_id
				$prevId = $data[0]; # update previous id
		}

		# attribute column
		$attrName = trim($data[2]);
		$attrName =~ s/\R//g; # \R is meta for \r\n and \n
		$attr = uri_escape($attrName);

		# value column
		$value = trim($data[4]);
		$value =~ s/\R//g; # \R is meta for \r\n and \n
		
		if ($value ne '') { # check for empty string
				print "$subj <$base#$attr> \"$value\"^^xsd:string .\n";
		}

		# collect attributes and their names in hash table for assigning rdfs labels
		if (not exists($attributes{$attr})) {
				$attributes{$attr} = "$attrName";
		}

		# collect harmonized names of attribute
		$harmName = trim($data[3]);
		$harmName =~ s/\R//g; # \R is meta for \r\n and \n
		if ($harmName ne '') {
				if (not exists($harmonized_names{$harmName})) {
						$harmonized_names{$attr} = "$harmName";
				}
		}
}

# write labels of attributes
while (my ($key, $value) = each(%attributes)) {
		print "<$base#$key> <rdfs:label> \"$value\"^^xsd:string .\n"; # assign rdfs label 
}

# write harmonized names of attributes
while (my ($key, $value) = each(%harmonized_names)) {
		print "<$base#$key> <$base:harmonized> \"$value\"^^xsd:string .\n"; # assign harmonized names 
}

