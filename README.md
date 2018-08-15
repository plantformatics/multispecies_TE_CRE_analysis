# multispecies_TE_CRE_analysis

Collection of scripts and wrappers used to analyze CRE evolution among different plant species via ATAC-seq data. The majority of code aims to deconvolute potential associations of CREs with repetitive elements and transposons. 

The main script iterates over different directories for each species.
- ```iterate_TE_pipe_species.sh```

This script launches the transposon intersection with ACRs and runs the simulation for significance enrichment. Need to provide two initials for each species. Code calls PBS to send processes to the gacrc cluster. Default is run at 40 threads. 
- ```qsub -F "At" map_ACRs_TEs.v4.sh``` 

Make sure all chromosome naming starts with *"chr"* and sorted using ```sort -k1,1 -k2,2n```

