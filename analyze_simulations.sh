#!/bin/bash

## submission properties

##------------------------------------------------------------------##
#PBS -S /bin/bash                       ## shell selection          ##
#PBS -q schmitz_q                       ## queue selection          ##
#PBS -N processTEacr_pipe               ## job name                 ##
#PBS -l nodes=1:ppn=40                  ## threading argument       ##
#PBS -l walltime=48:00:00               ## total time running limit ##
#PBS -l mem=60gb                        ## memory limit             ##
##------------------------------------------------------------------##


## change to directory
cd $PBS_O_WORKDIR

## ARGUMENTS
FA=$1
echo "${FA} running TE - ACR analysis for species $FA ..."


## generate intermediate files from temp

cp estimate_proportions_family.pl temp/
cd ./temp
for i in $(ls *.TE | rev | cut -c 4- | rev | uniq); do
	echo "perl estimate_proportions_family.pl ${i}.TE ${i} > ${i}.ACR_TEfamstats.txt" >> estimateprops_fam.txt
done


##-----------------------------##
## run reformating in parallel ##
##-----------------------------##
time parallel --joblog log2.fam.txt --jobs 40 < estimateprops_fam.txt

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

cat *.ACR_TEfamstats.txt > ${FA}.allTEfamstats.txt1
rm *.ACR_TEfamstats.txt

grep -v 'centromeric' ${FA}.allTEfamstats.txt1 > test
sed 's/Retroposon\tL1/Retroposon\tRetroposon/g' test > ${FA}.allTEfamstats.txt1

cp ${FA}.allTEfamstats.txt1 ../
rm test

cd ../

## cleanup allTEstats file

perl sumsim.pl ${FA}.allTEfamstats.txt1 > ${FA}.allTEfamstats.txt
rm ${FA}.allTEfamstats.txt1

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
cp ${FA}.allTEfamstats.txt ../data_analysis

## remove intermediate command files
rm estimateprops_fam.txt


############
## FINISH ##
############
