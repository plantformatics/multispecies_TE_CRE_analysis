#!/usr/bin/perl
use strict;
use warnings;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	for (my $i = 6; $i < 10; $i++){
		if($col[$i] > 0){
			
		}
	}
}
close F;
