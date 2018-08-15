#!/usr/bin/perl
use strict;
use warnings;

die "$0 [fcon.bed.sort] [species:At]" unless @ARGV == 2;

open F, $ARGV[0] or die;
my $species = $ARGV[1];
my $count = 0; 

while(<F>){
	chomp;
	$count++;
	my @col = split("\t",$_);
	my $tracker = join("_", $species,$col[5],$count);
	my $name = $tracker . ".1";

	## gene
	print "$col[0]\tRepeatMasker\tgene\t$col[1]\t$col[2]\t.\t$col[4]\t.\t";
	print "ID=$tracker;Name=$tracker;Family=$col[6];Class=$col[7]\n";
	
	## mRNA
	#print "$col[0]\tRepeatMasker\tmRNA\t$col[1]\t$col[2]\t.\t$col[4]\t.\t";
        #print "ID=$tracker.te;Name=$name.te;Family=$col[6];Class=$col[7]\tParent=$tracker\n";
	
	## TIRs
	if($col[5] !~ /\//){
		print "$col[0]\tRepeatMasker\tCDS\t$col[1]\t$col[2]\t.\t$col[4]\t0\t";
		print "Parent=$tracker\n";	
	}
	else{
		my $blocks = 0;
		my @sites = split(";",$col[$#col]);
		my @id = split(/\//,$col[5]);
		for (my $i = 0; $i < @sites; $i++){
			my @coord = split("_",$sites[$i]);
			print "$col[0]\tRepeatMasker\tCDS\t$coord[1]\t$coord[2]\t.\t$col[4]\t0\t";
			print "Parent=$tracker\n";
		}
	}
}
close F;
