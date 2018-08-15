#!/bin/bash

for i in */; do
	fa=${i:0:2}

	## check directory name
	if [[ $fa = "Es" ]]; then
		continue
	fi

	if [[ $fa = "Ao" ]]; then
		continue
	fi
	
	if [[ $fa = 'Bd' ]]; then
		continue
	fi

	if [[ $fa = 'Hv' ]]; then
		continue
	fi

	if [[ $fa = 'ol' ]]; then
		continue
	fi

	if [[ $fa = 'bi' ]]; then
		continue
	fi

	## for the good directories
	cp bin/*.pl bin/*.sh bin/*.R $i
        cd $i

	## for species with data, 
	## do the following 
	echo ""
	echo "cleaning the ${fa} genome..."

	## check if log files exists
	logss=`ls -1 processTEacr_pipe.* 2>/dev/null | wc -l`
	if [ $logss != 0 ]; then
	       rm processTEacr_pipe*
	fi
	
	## launch mapping script to cluster
	qsub -F ${fa} map_ACRs_TEs.v3.sh
	cd ../
done	
