#!/bin/bash

## submission properties

#PBS -S /bin/bash                       ## shell selection
#PBS -q batch                           ## queue selection
#PBS -N processTEacr_pipe               ## job name
#PBS -l nodes=50:ppn=1                  ## ppn=threads per node, Needs to match the software argument integer
#PBS -l walltime=24:00:00               ## total time running limit
#PBS -l mem=20gb                        ## memory limit

## change to directory
cd $PBS_O_WORKDIR

## ARGUMENTS
FA=$1

echo "${FA} running TE - ACR analysis for species $FA ..."

##################
## legacy usage ##
##################

## usage: map_ACRs_TEs.sh [ACR] [TE] [out prefix]
#if [[ $# -eq 0 ]] ; then
#    echo 'usage: map_ACRs_TEs.sh [ACR] [TE] [out prefix]'
#    exit 0
#fi

## check if ACR file exists otherwise, exit
if [ ! -f ${FA}.sum.bed ]; then
	exit 1
fi

## check if file is sorted
if [ ! -f ${FA}.sum.bed.sorted ]; then
	grep -v '#' ${FA}.sum.bed | sort -k1,1 -k2,2n - > ${FA}.sum.bed.sorted
fi

## check if TEs are sorted
if [ ! -f ${FA}.fa.out.fcon.bed.sorted ]; then
	grep -v '#' ${FA}.fa.out.fcon.bed | sort -k1,1 -k2,2n - > ${FA}.fa.out.fcon.bed.sorted
fi

## check if command lists are present
if [ -f commandlist.txt ]; then
	rm commandlist.txt
fi

################################################
## Perform some basic analysis of TEs on ACRs ##
################################################

## convert TE bed file to gff
perl convert_fconBED2gff.pl ${FA}.fa.out.fcon.bed.sorted ${FA} > ${FA}.rmaskTE.gff

## map TEs to ACRs
bedtools intersect -a ${FA}.sum.bed.sorted -b ${FA}.fa.out.fcon.bed.sorted -wa -wb -sorted > ${FA}.ACR_TEmapped.bed
bedtools intersect -a ${FA}.sum.bed.sorted -b ${FA}.fa.out.fcon.bed.sorted -c > ${FA}.cnt_teACR.bed
total=$(bedtools intersect -a ${FA}.sum.bed.sorted -b ${FA}.fa.out.fcon.bed.sorted -wa -sorted | uniq | wc -l)

## estimate coverages between ACR and TE
perl overlap_stats.pl ${FA}.ACR_TEmapped.bed > ${FA}.ACR_TEmapped.bed.cov

## summary stats 
perl summary_stats.pl ${FA}.ACR_TEmapped.bed.cov > ${FA}.ACR_TEstats.txt
sed 's/Retroposon\tL1/Retroposon\tRetroposon/g' ${FA}.ACR_TEstats.txt > test
mv test ${FA}.ACR_TEstats.txt

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

## specific TE families
for i in `seq 1 10000`; do
	echo "bedtools shuffle -i ${FA}.sum.bed.sorted -g ${FA}.fa.fai -excl ${FA}.sum.bed.sorted -chrom |sort -k1,1 -k2,2n - |bedtools intersect -a - -b ${FA}.fa.out.fcon.bed.sorted -sorted -wa -wb | uniq - > ./temp/$i.TE" >> commandlist.txt
done

## run in parallel
time parallel --jobs 50 < commandlist.txt

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
	perl estimate_proportions.pl ${i}.TE ${i} > ${i}.ACR_TEstats.txt
done

## append to family-specific TE files
cat *.ACR_TEstats.txt > allTEstats.txt
rm *.ACR_TEstats.txt
grep -v 'centromeric' allTEstats.txt > test
sed 's/Retroposon\tL1/Retroposon\tRetroposon/g' test > allTEstats.txt
cp allTEstats.txt ../
rm test

cd ../

## remove intermediate command files
rm commandlist.txt

############
## FINISH ##
############
