#!/bin/bash

## submission properties

##------------------------------------------------------------------##
#PBS -S /bin/bash                       ## shell selection          ##
#PBS -q batch                           ## queue selection          ##
#PBS -N processTEacr_pipe               ## job name                 ##
#PBS -l nodes=40:ppn=1                  ## threading argument       ##
#PBS -l walltime=48:00:00               ## total time running limit ##
#PBS -l mem=10gb                        ## memory limit             ##
##------------------------------------------------------------------##


## change to directory
cd $PBS_O_WORKDIR

## ARGUMENTS
FA=$1
echo "${FA} running TE - ACR analysis for species $FA ..."

## check if ACR file exists otherwise, exit
if [ ! -f ${FA}.sum.bed ]; then
	exit 1
fi

## check if file is sorted
if [ ! -f ${FA}.sum.bed.sorted ]; then
	grep -v '#' ${FA}.sum.bed | perl clean_ACR_ori.pl - |sort -k1,1 -k2,2n - > ${FA}.sum.bed.sorted
fi

## check if TEs are sorted
if [ ! -f ${FA}.fa.out.fcon.bed.sorted ]; then
	grep -v '#' ${FA}.fa.out.fcon.bed | sort -k1,1 -k2,2n - > ${FA}.fa.out.fcon.bed.sorted
fi

## check if command lists are present
if [ -f commandlist.txt ]; then
	rm commandlist.txt
fi

if [ -f estimateprops.txt ]; then
	rm estimateprops.txt
fi


##------------------------------------------##
## coodindate chromosome naming conventions ##
##------------------------------------------##

## reference index
sed 's/Chr/chr/g' ${FA}.fa.fai > test
perl -ne 'chomp;if($_ =~/^chr\d+/){print"$_\n";}' test > ${FA}.fa.fai

## gene annotation
sed 's/Chr/chr/g' ${FA}.gene.gff > test 
perl -ne 'chomp;if($_ =~/^chr\d+/){print"$_\n";}' test > ${FA}.gene.gff

## ACRs
sed 's/Chr/chr/g' ${FA}.sum.bed.sorted > test 
perl -ne 'chomp;if($_ =~/^chr\d+/){print"$_\n";}' test > ${FA}.sum.bed.sorted

## TE file
sed 's/Chr/chr/g' ${FA}.fa.out.fcon.bed.sorted > test
perl -ne 'chomp;if($_ =~/^chr\d+/){print"$_\n";}' test > ${FA}.fa.out.fcon.bed.sorted


##----------------------------------------##
## check if essential files are populated ##
##----------------------------------------##

## reference index
if [ ! -s ${FA}.fa.fai ]; then
	echo "problem with ${FA}.fa.fai..."
	exit 1
fi

## gene annotation
if [ ! -s ${FA}.gene.gff ]; then
        echo "problem with ${FA}.gene.gff..."
        exit 1
fi

## ACR file
if [ ! -s ${FA}.sum.bed.sorted ]; then
        echo "problem with ${FA}.sum.bed.sorted..."
        exit 1
fi

## TE file
if [ ! -s ${FA}.fa.out.fcon.bed.sorted ]; then
        echo "problem with ${FA}.fa.out.fcon.bed.sorted..."
        exit 1
fi

echo "finished creating and cleaning input files..."


###########################################
## split ACRs into the following: 	 ##
## 	genic,				 ##
## 	proximal (2kb TSS, 1kb TTS), and ##
## 	distal (putative enhancers)      ##
###########################################

## extract genomic features using gene annotations
perl extract_genic_flanking_intergenic.pl ${FA}.gene.gff ${FA} ${FA}.fa.fai

## make intergenic regions
bedtools subtract -a ${FA}.chrom.bed -b ${FA}.genic.gff | \
	bedtools subtract -a - -b ${FA}.promoters.gff | \
	bedtools subtract -a - -b ${FA}.downstream.gff > ${FA}.intergenic.bed

## annotate ACR by percent coverage each feature |intergenic|promoter|gene|downstream
perl -ne 'chomp;my@col=split("\t",$_);my$up=$col[3]-1;my$id=join("_",@col[0..4]);print"$col[0]\t$up\t$col[3]\t$id\n";' \
	${FA}.sum.bed.sorted > ${FA}.sum.bed.sorted.peak
bedtools annotate -i ${FA}.sum.bed.sorted.peak -files ${FA}.intergenic.bed ${FA}.promoters.gff ${FA}.genic.gff ${FA}.downstream.gff | \
	sort -k1,1 -k2,2n - > ${FA}.annotated.ACR.bed.pre
perl convert2annotated.pl ${FA}.annotated.ACR.bed.pre > ${FA}.annotated.ACR.bed
bedtools closest -D ref -a ${FA}.annotated.ACR.bed -b ${FA}.fa.out.fcon.bed.sorted > ${FA}.annotated.ACR.distTE.bed

echo "finished annotating ACRs..."

## remove intermediate files by uncommenting V
rm ${FA}.annotated.ACR.bed.pre
rm ${FA}.sum.bed.sorted.peak


################################################
## Perform some basic analysis of TEs on ACRs ##
################################################

## convert TE bed file to gff
perl convert_fconBED2gff.pl ${FA}.fa.out.fcon.bed.sorted ${FA} > ${FA}.rmaskTE.gff

## map TEs to ACRs
## TEs must overlap ACR peak
bedtools intersect -a ${FA}.annotated.ACR.bed -b ${FA}.fa.out.fcon.bed.sorted -wa -wb -sorted -f 0.2 > ${FA}.ACR_TEmapped.bed
#perl select_teACR_overlap.pl ${FA}.ACR_TEmapped.basic.bed > ${FA}.ACR_TEmapped.bed

## estimate coverages between ACR and TE
perl overlap_stats.pl ${FA}.ACR_TEmapped.bed > ${FA}.ACR_TEmapped.bed.cov
sed 's/L1\tRetroposon/Retroposon\tRetroposon/g' ${FA}.ACR_TEmapped.bed.cov > test
mv test ${FA}.ACR_TEmapped.bed.cov
perl call_feature.pl ${FA}.ACR_TEmapped.bed.cov > ${FA}.ACR_TEmapped.bed.GF.cov

## summary stats 
perl summary_stats.pl ${FA}.ACR_TEmapped.bed.cov > ${FA}.ACR_TEstats.txt
sed 's/Retroposon\tL1/Retroposon\tRetroposon/g' ${FA}.ACR_TEstats.txt > test
mv test ${FA}.ACR_TEstats.txt

echo "finished determining basic statistics of ACRs..."

## remove intermediate files by uncommenting
#rm ${FA}.ACR_TEmapped.bed
#rm ${FA}.ACR_TEmapped.basic.bed

######################################
## test association (MC simulation) ##
######################################

## check if temp is a directory
if [ -d 'temp' ]; 
	then
		rm -r ./temp; mkdir temp
	else
		mkdir temp
fi
cp estimate_proportions.pl ./temp

echo "begin ACR permutation..."

## create command file
for i in `seq 1 10000`; do
        echo "bedtools shuffle -i ${FA}.sum.bed.sorted -g ${FA}.fa.fai -excl ${FA}.sum.bed.sorted | bedtools annotate -i - -files ${FA}.intergenic.bed ${FA}.promoters.gff ${FA}.genic.gff ${FA}.downstream.gff | sort -k1,1 -k2,2n - | bedtools intersect -a - -b ${FA}.fa.out.fcon.bed.sorted -sorted -wa -wb -f 0.2 | uniq - > ./temp/$i.TE" >> commandlist.txt
done


##-----------------------------##
## run simulations in parallel ##
##-----------------------------##
time parallel --joblog log.txt --jobs 40 < commandlist.txt

while [ -n "$PARALLEL_ENV" ]; do
	(( num++ ))
        sleep 5;
       	if (( $num % 6 == 0 ))
                then
                now=$(date +"%T")
                echo "Current time : $now"
        fi
done;


## generate intermediate files from temp
cd ./temp
for i in $(ls *.TE | rev | cut -c 4- | rev | uniq); do
	echo "perl estimate_proportions.pl ${i}.TE ${i} > ${i}.ACR_TEstats.txt" >> estimateprops.txt
done


##-----------------------------##
## run reformating in parallel ##
##-----------------------------##
time parallel --joblog log2.txt --jobs 40 < estimateprops.txt

while [ -n "$PARALLEL_ENV" ]; do
	(( num++ ))
        sleep 5;
       	if (( $num % 6 == 0 ))
                then
                now=$(date +"%T")
                echo "Current time : $now"
        fi
done;


##------------------------------------##
## append to family-specific TE files ##
##------------------------------------##
cat *.ACR_TEstats.txt > ${FA}.allTEstats.txt1
rm *.ACR_TEstats.txt

grep -v 'centromeric' ${FA}.allTEstats.txt1 > test
sed 's/Retroposon\tL1/Retroposon\tRetroposon/g' test > ${FA}.allTEstats.txt1

cp ${FA}.allTEstats.txt1 ../
rm test

cd ../

## cleanup allTEstats file
perl sumsim.pl ${FA}.allTEstats.txt1 > ${FA}.allTEstats.txt
rm ${FA}.allTEstats.txt1 


##-------------------------------------##
## check if bin_scripts is a directory ##
## move scripts to directory	       ##
##-------------------------------------##
if [ -d 'bin_scripts' ];
        then
                rm -r ./bin_scripts; mkdir bin_scripts
        else
                mkdir bin_scripts
fi

mv *.pl *.sh bin_scripts/

## copy select files to data analysis directory
cp ${FA}.allTEstats.txt ${FA}.annotated.ACR.distTE.bed ${FA}.ACR_TEmapped.bed.GF.cov ${FA}.ACR_TEstats.txt ../data_analysis

## remove intermediate command files
rm commandlist.txt
rm estimateprops.txt



############
## FINISH ##
############
