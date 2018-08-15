#!/usr/bin/perl
use strict;
use warnings;
use Sort::Naturally;


my %hash;
my %types;
open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	if(! $hash{$col[0]}{$col[1]}){
		$hash{$col[0]}{$col[1]} = $col[2];
	}
	my $bb;
	if(! $hash{$col[0]}{'TE'}){
		$hash{$col[0]}{'TE'} = $col[3];
	}
	$types{$col[1]} = 1;
}
close F;

$types{'TE'} = 1;

my @keys = nsort keys %hash;
my @type = nsort keys %types;
for (my $i = 0; $i < @keys; $i++){
	if($i == 0){
		print "$type[0]";
		foreach(@type[1..$#type]){
			print "\t$_";
		}
		print "\n";
	}
	if(exists $hash{$keys[$i]}{$type[0]}){
		print "$hash{$keys[$i]}{$type[0]}";
	}
	else{
		print "0";
	}
	for (my $j = 1; $j < @type; $j++){
		if(exists $hash{$keys[$i]}{$type[$j]}){
			print "\t$hash{$keys[$i]}{$type[$j]}"
		}
		else{
			print "\t0";
		}
	}
	print "\n";
}
