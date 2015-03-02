# seastar
Assembly information

## Assembled Sample Data

    SAMN02867504	V31	Feb 13, 2015	967	533	Feb 13, 2015	SRR1802991	SRS845312	V31	10/26/2013	USA	Pycnopodia helianthoides	Asymptomatic	D	47.6097 N 122.3331 W	WGA	<not provided>	PRJNA253121	MIMS.me	CORNELL	public	0	ILLUMINA	SRP043427	ocean	coastal_water	animal_associated_habitat	<not provided>	<not provided>	<not provided>

## Graph interpretation

Each cirle in the graph represents an assembled contig; the area of each
circle is proportional to the length of the contig sequence. The color 
indicates GC richness. Each black arrow represents the connection between
two mate pairs; the thickness of the black arrows represents the "bitscore".
Red arrows are "added dependencies to produce a fully ordered layout for 
"SCAFF".

## Problems on the cluster
    /home/mtomko/share/data/fastq/asymptomatic/SEAStAR.sh: line 24: 26425 Killed                  ${VELPATH}/velvetg_de asymptomatic_asm/ -scaffolding no -read_trkg no -ins_length auto -ins_length_sd auto -exp_cov 50 -cov_cutoff 5 -min_contig_lgth 50 > asymptomatic_asm.velvetg_de.log 2>&1


## SEAStAR documentation

The user guide is located at:

https://github.com/armbrustlab/SEAStAR/blob/master/documentation/SEAStAR_User_Guide.md
