#!/usr/bin/perl
use strict;
use warnings;
use Sort::Naturally;

die "$0 [ACR_TE_file]" unless @ARGV == 1;

my %hash;

# load ACR/TE into hash
open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my @col = split("\t",$_);
	my $ACR = join("_", @col[0..4]);
	my $TE = join("_",@col[9..11]);
	$hash{$ACR}{$TE}=$_;
}
close F;

# iterate over unique ACRs
my @acrs = nsort keys %hash;
for (my $i = 0; $i < @acrs; $i++){
	my @tes = nsort keys %{$hash{$acrs[$i]}};
	my @acr_cor = split("_", $acrs[$i]);
	for (my $j = 0; $j < @tes; $j++){
		my @col = split("\t",$hash{$acrs[$i]}{$tes[$j]});
		my $te = join("_",@col[9..11]);
		
		# skip TEs < 50 bp
		if(($col[11] - $col[10]) < 50){
			print STDERR "skipped => \t$hash{$acrs[$i]}{$tes[$j]}\n";
			next;
		}		

		# print ACR coordinates
		foreach(@acr_cor){
			print "$_\t";
		}
		print "ACRid$i";

		# print TE coordinates
		foreach(@col[5..11]){
			print "\t$_";
		}

		# find coverage overlap
		my @coverages = coverage($acrs[$i], $tes[$j]);
		print "\t$coverages[0]\t$coverages[1]";
		foreach(@col[13..$#col]){
			print "\t$_";
		}
		print "\n";
	}
}


## subroutines
sub coverage{
	my ($site1, $site2) = @_;
	my @acrc = split("_",$site1);
	my @tesc = split("_",$site2);
	my $acr_cov;
	my $tes_cov;
	my $len_acr = $acrc[2] - $acrc[1];
	my $len_tes = $tesc[2] - $tesc[1];
	if($tesc[1] >= $acrc[1] && $tesc[1] < $acrc[2] && $tesc[2] >= $acrc[2]){
		$acr_cov = ($acrc[2] - $tesc[1])/$len_acr;
		$tes_cov = ($acrc[2] - $tesc[1])/$len_tes;
	}
	elsif($tesc[1] >= $acrc[1] && $tesc[2] <= $acrc[2]){
		$acr_cov = ($tesc[2] - $tesc[1])/$len_acr;
		$tes_cov = 1;
	}
	elsif($acrc[1] >= $tesc[1] && $acrc[2] <= $tesc[2]){
		$acr_cov = 1;
		$tes_cov = $len_acr/$len_tes;
	}
	elsif($tesc[1] < $acrc[1] && $tesc[2] >= $acrc[1] && $tesc[2] <= $acrc[2]){
		$acr_cov = ($tesc[2] - $acrc[1])/$len_acr;
		$tes_cov = ($tesc[2] - $acrc[1])/$len_tes;
	}
	return($acr_cov, $tes_cov);
}
