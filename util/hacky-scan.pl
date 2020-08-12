#!/usr/bin/perl -n
if (m@.*harmonized_name="(\S+)".*">(.*)</Attribute>@) {
    print "$1\t$2\n";
}
