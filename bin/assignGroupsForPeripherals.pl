#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($result);

&GetOptions("result=s"=> \$result);

open(my $data, '<', $result) || die "Could not open file $result: $!";
my @geneList = ();
while (my $line = <$data>) {
    chomp $line;
    if ($line =~ /^>\S+\sgene=(\S+)\sproduct=\S+/) {
        my $gene = $1;
	if ( grep( /^$gene/, @geneList ) ) {
             die "found $gene";
        }
	push @geneList, $gene;
    }
}	
