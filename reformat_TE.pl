#!/usr/bin/perl
use strict;
use warnings;

open F, $ARGV[0] or die;

print "#Chr\tstr\tend\tTE_id\tstrand\tname\tid\tclass\tdiv\tcoverage\talign\ttotal\tscore\n";

my $it = 0;
while(<F>){
	chomp;
	$it++;
	if($it < 4){
		next;
	}
	$_ =~ s/\(//g;
	$_ =~ s/\)//g;
	$_ =~ s/^\s+//;
	my @col = split(/\s+/,$_);
	if($_ =~ /tRNA/){
		next;
	}
	elsif($_ =~ /\*/){
		next;
	}
	else{
		my $chr = $col[4];
		my $start = $col[5];
		my $end = $col[6];
		if(($end - $start) < 50){
			next;
		}
		my $total = 0;
		my $strand = '+';
		my $align = 0;
		my $cov = 0;
		my @names = split("/",$col[10]);
		if(@names < 2){
			next;
		}
		if($col[8] eq '+'){
			$strand = '+';	
			$total = $col[13] + $col[12];
			$align = $col[12] - $col[11] + 1;
			$cov = $align/$total;
		}
		else{
			$strand = '-';
			$total = $col[11] + $col[12];
			$align = $col[12] - $col[13];
			$cov = $align/$total;
		}
		print "$chr\t$start\t$end\t$col[14]\t$strand\t";
		print "$col[9]\t$names[1]\t$names[0]\t$col[1]\t$cov\t$align\t$total\t$col[0]\n";

	}	
}
close F;
