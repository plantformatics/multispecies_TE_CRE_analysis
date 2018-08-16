#!/usr/bin/perl
use strict;
use warnings;
use Sort::Naturally;

my %hash;
my %total;
my $all = 0;
my $count = 0;
my %acr;

die "$0 <#.TE> <#>" unless @ARGV == 2;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	my $id = join("_",@col[0..4]);
	if(! $acr{$id}){
		$count++;
		$acr{$id}++;
	}
        $hash{$col[15]}{$id}++;
}
close F;

my @keys = nsort keys %hash;
for (my $i = 0; $i < @keys; $i++){
	my @te = nsort keys %{$hash{$keys[$i]}};
	my $num = @te;
	print "$ARGV[0]\t$keys[$i]\t$num\t$count\n";
}

