#!/usr/bin/perl
use Text::Trim 'trim';
use utf8;
binmode STDOUT, ":utf8";

# hash table to hold attribute values
my %attributes = ();

# default values
my $header = "primary_id";
my $primaryId = "";
my $prevId = "";
my @data = ();
my $firstIter = 1;

# open input file
open (FH, "<", $ARGV[0]) or die $!;

# add attributes to hash table
my $line = <>; # skip header
while($line = <FH>) {
		@data = split(/\t/, $line);

		# attribute column
		$attrName = trim($data[1]);
		$attrName =~ s/\R//g; # \R is meta for \r\n and \n
		
		if ((not exists($attributes{$attrName})) and ($attrName ne '')) {
						$attributes{$attrName} = "";
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
$line = <FH>; # skip header
while($line = <FH>) {
		@data = split(/\t/, $line); # put data into array
		$primaryId = $data[0]; 	# collect primary id

		if ($firstIter > 0) {
				$prevId = $primaryId; # on first iteration set the previous id
				$firstIter = 0; # set first iteration set flag to 0
		}
		
		# check to see if we've reached a new set of ids
		if ($prevId ne $primaryId) {
				# print collected data
				print "$prevId"; # print primary id; note this will be the previous id
				foreach $value (values %attributes) { print "\t$value";} 	# print attribute values
				print "\n"; # end of line
				
				# reset attributes
				foreach $key (keys %attributes) { $attributes{$key} = ""; }
						
				$prevId = $primaryId; # update the previous id
		}

		# collect attribute name
		$attrName = trim($data[1]);
		$attrName =~ s/\R//g; # \R is meta for \r\n and \n
		
		# collect value
		$value = trim($data[2]);
		$value =~ s/\R//g; # \R is meta for \r\n and \n

		if ($value ne '') { # check for empty string
				$attributes{$attrName} = $value;
		}
}

# after loop finishes there is still one set of data to print
print "$primaryId"; # print primary id
foreach $value (values %attributes) { print "\t$value";} 	# print attribute values
print "\n"; # end of line
