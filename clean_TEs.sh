#!/bin/bash

## specific arguments

tempfiles=false
#file=1

while getopts "htf:" opt; do
	case ${opt} in
		h ) 
			echo "Usage: clean_TEs.sh [-h|help] [-t|temp files] {-f|RM_output}"
		    	exit 0
			;;

		t ) 	tempfiles=true
			;;

		f )	file=$OPTARG
			;;

		\? ) 	echo "Usage: clean_TEs.sh [-h|help] [-t|temp files] {-f|RM_output}"
			exit 1
			;;

		: ) 	echo "Invalid option: $OPTARG requires an argument" 1>&2
			exit 1
			;;
	esac
done

## check if file is supplied
if [ -z ${file+x} ];
        then
                echo "missing input file...";
		echo ""
		echo "Usage: clean_TEs.sh [-h|help] [-t|flag rm temp files] {-f|RM_output}";
                exit 1;
fi

## remove Low complexity and simple repeats
grep -v Low_complexity $file > $file.noLC
grep -v Simple_repeat $file.noLC > $file.noLCSR
grep -v Satellite $file.noLCSR > $file.noLCSRS

## updates
echo "Low complexity, simple repeats and satellite repeats were removed in that order..."
if [ "$tempfiles" = false ];
	then
		echo "... and can be found in the files..."
		echo "	1) $file.noLC"
		echo "	2) $file.noLCSR"
		echo "	3) $file.noLCSRS"
		echo ""
fi

## clean weird annotations
echo "Reformating and filtering transposons..."
sed 's/?//g' $file.noLCSRS > $file.noLCSR_q

#############################
## reformat and filter TEs ##
#############################
perl reformat_TE.pl $file.noLCSR_q > $file.cleaned.bed
perl filter_TE.pl $file.cleaned.bed > $file.fcon.bed 				## final output file

## remove intermediate files
rm $file.noLCSR_q $file.cleaned.bed

## update the user
echo "Reformat and filtering complete..."

## remove temp files if -t is set
if $tempfiles
	then
		echo "-t flag set, removing temporary files..."
		rm $file.noLC $file.noLCSR $file.noLCSRS 
fi
