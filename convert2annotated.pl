#!/usr/bin/perl
use strict;
use warnings;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	my @coords = split("_",$col[3]);
	foreach(@coords){
		print "$_\t";
	}
	print "$col[4]\t$col[5]\t$col[6]\t$col[7]\n";
}
close F;
