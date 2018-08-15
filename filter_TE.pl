#!/usr/bin/perl
use strict;
use warnings;
use Sort::Naturally;

my %hash;

open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	if($_ =~ /#/){
		print "$_\tRepeatCoordinates\n";
		next;
	}
	else{
		push(@{$hash{$col[3]}}, $_);	
	}
}
close F;

my @keys = nsort keys %hash;
for (my $i = 0; $i < @keys; $i++){
	my @counts = @{$hash{$keys[$i]}};
	if(@counts == 1){
		my @line = split("\t",$counts[0]);
		my $coord = join("_", @line[0..2]);
		print "$counts[0]\t$coord\n";
	}
	else{
		my @coords;
		my @div;
		my @type;
		my @cov;
		my @score;
		my @aligns;
		my @sites;
		foreach my $te (@counts){
			my @line = split("\t",$te);
			my $cc = join("_", @line[0..2]);
			push(@sites, $cc);
			push(@type, $line[5]);
			push(@coords, $line[1], $line[2]);
			push(@div, $line[8]);
			push(@cov, $line[9]);
			push(@aligns, $line[10]);
			push(@score, $line[12]);
		}
		my @sorted = sort {$a <=> $b} @coords;
		my @rep = split("\t",$counts[0]);
		my $tes = join("/",@type);
		my $divs = mean(@div);
		my $covs = 0;
		foreach(@cov){
			$covs = $covs + $_;
		}
		my $scor = mean(@score);
		my $aln = join(";", @aligns);
		my $coordinates = join(";", @sites);
		my $total_frag = $sorted[$#sorted] - $sorted[0];
		if($total_frag < 50){
			next;
		}
		print "$rep[0]\t$sorted[0]\t$sorted[$#sorted]\t";
		print "$keys[$i]\t$rep[4]\t$tes\t$rep[6]\t$rep[7]\t";
		print "$divs\t$covs\t$aln\t$rep[11]\t$scor\t$coordinates\n"
	}
}

## subroutines
sub mean{
	my (@num) = @_;
	my $total = 0;
	foreach(@num){
		$total = $total + $_;
	}
	my $average = $total/@num;
	return($average);
}
