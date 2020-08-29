#!/usr/bin/perl
use Text::Trim 'trim';


# has table to hold attribute values
my %attributes = ();

# default values
my $header = "primary_id\tsra_id";
my $primaryId = "";
my $sraId = "";

# open input file
open (FH, "<", $ARGV[0]) or die $!;

# add attributes to hash table
while(<FH>) {
		trim;
		if (m@^<Attribute attribute_name="(.+?)"@) {
				if (not exists($attributes{$1})) {
						$attributes{$1} = "";
				}
		}
}

# test printing out attributes
# while ( ($k,$v) = each %attributes ) {
# 		print "$k => '$v' \n";
# }


# print header of document
print $header; # print first part of header
foreach $key (keys %attributes) { print "\t$key"; } # print attributer names
print "\n"; # end header line

# return to beginning of file to gather values
seek FH, 0, 0 ; 
while(<FH>) {
		trim; # remove leading/trailing spaces
		# print "$_\n";

		if (m@^<Id .*is_primary="1">(.+?)</Id>$@) {
				$primaryId = $1;
		}


		if (m@^<Id db="SRA">(.+?)</Id>$@) { # information seems uneeded
				$sraId = $1;
    }
		
		# we only to output rows with values (i.e. (.+)); set hash value
		if (m@^<Attribute attribute_name="(.+?)".*>(.+?)</Attribute>$@) {
				$attributes{$1} = $2;

		}

		if (m@^</BioSample>$@) { # we've reached the end of a biosample block
				# print values for first part of header
				print "$primaryId\t$sraId";
						
				# print attribute values
				foreach $value (values %attributes) { print "\t$value";}

				print "\n"; # end of header
				
				# reset default values
				$primaryId = "";
				$sraId = "";

				# reset attributes
				foreach $key (keys %attributes) {
						$attributes{$key} = "";
				}
		}
}


