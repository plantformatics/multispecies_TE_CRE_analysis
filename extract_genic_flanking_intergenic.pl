#!/usr/bin/perl
use strict;
use warnings;
use Sort::Naturally;

die "$0 [species.sum.bed.sorted] [species] [species.fa.fai]\n" unless @ARGV == 3;

## output files
my $promoter = $ARGV[1] . ".promoters.gff";
my $genic = $ARGV[1] . ".genic.gff";
my $downstream = $ARGV[1] . ".downstream.gff";
my $chromosome = $ARGV[1] . ".chrom.bed";

open (my $t1, '>', $promoter) or die;
open (my $t2, '>', $genic) or die;
open (my $t3, '>', $downstream) or die;
open (my $t4, '>', $chromosome) or die;

## load reference file
my %fai;
open G, $ARGV[2] or die;
while(<G>){
	chomp;
	my @col = split("\t",$_);
	$fai{$col[0]} = $col[1];
	print $t4 "$col[0]\t0\t$col[1]\n";
}
close G;


## iterate through GFF
open F, $ARGV[0] or die;
while(<F>){
	chomp;
	if($_ =~ /##/){
		next;
	}
	else{
		my @col = split("\t",$_);
		my @rep = @col;
		if($col[2] =~ /gene/){
			print $t2 "$_\n";
			
			## fix malformed GFF
			if($col[3] > $col[4]){
				$col[3] = $rep[4];
				$col[4] = $rep[3];
				if($col[6] eq '+'){
					$col[6] = '-';
				}
				else{
					$col[6] = '-';
				}
				print STDERR "flip @rep\nto   @col\n";
			}			
			my @prom = @col;
			my @down = @col;

			if($col[6] eq '-'){

				## annotate promoter
				$prom[3] = $col[4];
				$prom[4] = $col[4] + 2000;
				$prom[2] = 'promoter:<=';
				#if($prom[4] > $fai{$col[0]}){
				#	$prom[4] = $fai{$col[0]};
				#}
				my $tss = join("\t",@prom);
				print $t1 "$tss\n";

				## annotate downstream
				$down[3] = $col[3] - 1000;
				$down[4] = $col[3];
				$down[2] = 'downstream_1kb:<=';
				if($down[3] < 0){
					$down[3] = 1;
				}
				my $tts = join("\t",@down);
				print $t3 "$tts\n";
			}
			elsif($col[6] eq '+'){
				
				## annotate promoter (+)
				$prom[3] = $col[3] - 2000;
				$prom[4] = $col[3];
				$prom[2] = 'promoter:=>';
				if($prom[3] < 0){
					$prom[3] = 1;
				}
				my $tss = join("\t",@prom);
				print $t1 "$tss\n";
	
				## annotate downstream (+)
				$down[3] = $col[4];
				$down[4] = $col[4] + 1000;
				$down[2] = 'downstream_1kb:=>';
				#if($down[4] > $fai{$col[0]}){
				#	$down[4] = $fai{$col[0]};
				#}
				my $tts = join("\t",@down);
				print $t3 "$tts\n";
			}
		}
	}
}
close F;
