#!/usr/bin/perl
use strict;
use warnings;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	my @calls;
	for (my $i = 6; $i < 10; $i++){
		if($col[$i] >= 0.25){
			my $cc;
			if($i == 6){
				$cc = 'distal';
			}
			elsif($i == 7){
				$cc = 'promoter';
			}
			elsif($i == 8){
				$cc = 'genic';
			}
			elsif($i == 9){
				$cc = 'downstream';
			}
			push(@calls, $cc);
		}	
	}
	foreach(@calls){
		print "$col[0]";
		for (my $j = 1; $j < @col; $j++){
			if($j >= 6 && $j <= 8){
				next;
			}
			elsif($j == 9){
				print "\t$_";
			}
			else{
				print "\t$col[$j]";
			}
		}
		print "\n";
	}
}
close F;
