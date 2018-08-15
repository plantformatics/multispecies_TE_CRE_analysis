#!/usr/bin/perl
use strict;
use warnings;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	my $peak = $col[3];
	if($col[10] <= $peak && $col[11] <= $peak){
		print "$_\n";
	}
}
close F;
