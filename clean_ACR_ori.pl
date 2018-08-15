#!/usr/bin/perl
use strict;
use warnings;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	my @rep = @col;
	if($rep[2] > $rep[1]){
		$col[1] = $rep[2];
		$col[2] = $rep[1];
	}
	my $line = join("\t",@col);
	print "$line\n";
}
close F;
