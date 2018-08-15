#!/usr/bin/perl
use strict;
use warnings;
use Sort::Naturally;

my %hash;
my %total;
my $all = 0;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	$hash{$col[18]}{$col[17]}++;
	$total{$col[18]}++;
	$all++;
}
close F;

my @class = nsort keys %hash;

## iterate over TEs
print "#class\tfamily\tcount\tclassCnt\tTEtotal\t%class\t%total\n";
for (my $i = 0; $i < @class; $i++){
	my @family = nsort keys %{$hash{$class[$i]}};
	for (my $j = 0; $j < @family; $j++){
		my $fraction_class = $hash{$class[$i]}{$family[$j]}/$total{$class[$i]};
		my $fraction_total = $hash{$class[$i]}{$family[$j]}/$all;
		print "$class[$i]\t$family[$j]\t$hash{$class[$i]}{$family[$j]}\t$total{$class[$i]}\t$all\t";
		print "$fraction_class\t$fraction_total\n";
	}
}

## subroutines ##
sub average{
	my ($list) = @_;
	my @vals = @$list;
	my $total = 0;
	foreach(@vals){
		$total = $total + $_;
	}
	my $average = $total/@vals;
	return($average);
}
