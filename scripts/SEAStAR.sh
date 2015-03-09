#!/bin/sh

FILE_BASE=$1
SSPATH=/home/mtomko/share/SEAStAR/bin
VELPATH=/home/mtomko/share/velvet
BWAPATH=/home/mtomko/share/bwa

export PATH=${PATH}:${SSPATH}

# step 0: gunzip fastq files
#gunzip *.fastq.gz

# step 1: remove presumed PCR duplicate reads
$SSPATH/fastq_nodup -z -l 13 -d 2 -e 3 $FILE_BASE ${FILE_BASE}_dedup

# step 2: trim and filter the de-duplicated FASTQ reads based on quality,
#         information content, and length
$SSPATH/trimfastq -z --mates_file -p 0.9 -l 34 -m 34 --add_len -e 3.0 \
                  ${FILE_BASE}_dedup ${FILE_BASE}_trim

# step 3: perform assembly
${VELPATH}/velveth_de ${FILE_BASE}_asm/ 19 -fastq.gz \
           -shortPaired ${FILE_BASE}_trim.mates.fastq.gz \
           -short ${FILE_BASE}_trim.single.fastq.gz > ${FILE_BASE}_asm.velveth_de.log 2>&1

${VELPATH}/velvetg_de ${FILE_BASE}_asm/ -scaffolding no -read_trkg no \
           -ins_length auto -ins_length_sd auto -exp_cov 50 \
           -cov_cutoff 5 -min_contig_lgth 50 > ${FILE_BASE}_asm.velvetg_de.log 2>&1

# step 4: align reads to a reference
${SSPATH}/csfasta2ntfasta.awk ${FILE_BASE}_asm/contigs.fa > ${FILE_BASE}_contigs.fna

# create bwa index
${BWAPATH}/bwa index -a is -c ${FILE_BASE}_contigs.fna

# 4a: read1
${BWAPATH}/bwa aln -c -n 0.001 -l 18 ${FILE_BASE}_contigs.fna \
          ${FILE_BASE}_trim.read1.fastq.gz > ${FILE_BASE}_trim.read1.sai
${BWAPATH}/bwa samse -n 1000000 ${FILE_BASE}_contigs.fna \
          ${FILE_BASE}_trim.read1.sai \
          ${FILE_BASE}_trim.read1.fastq.gz 2>${FILE_BASE}_trim.read1.samse.log > ${FILE_BASE}_trim.read1.sam

# 4b: read2
${BWAPATH}/bwa aln -c -n 0.001 -l 18 ${FILE_BASE}_contigs.fna \
          ${FILE_BASE}_trim.read2.fastq.gz > ${FILE_BASE}_trim.read2.sai
${BWAPATH}/bwa samse -n 1000000 ${FILE_BASE}_contigs.fna \
          ${FILE_BASE}_trim.read2.sai ${FILE_BASE}_trim.read2.fastq.gz 2> ${FILE_BASE}_trim.read2.samse.log > ${FILE_BASE}_trim.read2.sam

# 4c: singletons (may not be any)
${BWAPATH}/bwa aln -c -n 0.001 -l 18 ${FILE_BASE}_contigs.fna \
          ${FILE_BASE}_trim.single.fastq.gz > ${FILE_BASE}_trim.single.sai
${BWAPATH}/bwa samse -n 1000000 ${FILE_BASE}_contigs.fna \
          ${FILE_BASE}_trim.single.sai ${FILE_BASE}_trim.single.fastq.gz 2>${FILE_BASE}_trim.single.samse.log > ${FILE_BASE}_trim.single.sam

# step 5: constructing an assembly graph
${SSPATH}/ref_select -q -m --mp_mate_cnt=10 \
         -r ${FILE_BASE}_trim.read1.fastq.gz \
         -r ${FILE_BASE}_trim.read2.fastq.gz \
         -r ${FILE_BASE}_trim.single.fastq.gz \
         ${FILE_BASE}_trim.read1.sam \
         ${FILE_BASE}_trim.read2.sam \
         ${FILE_BASE}_trim.single.sam > ${FILE_BASE}_asm.json

# step 6: producing scaffolded sequence

# make the viz file
echo "# Sample script file for SEAStAR graph_ops tool" > ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo 'MST' >> ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo 'PLUCK' >> ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo 'PRUNE' >> ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo 'PUSH' >> ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo 'INSERT' >> ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo 'SCAFF' >> ${FILE_BASE}.go
echo "DOT {\"file\":\"${FILE_BASE}_asm#.dot\"}" >> ${FILE_BASE}.go
echo "FASTA {\"scaff\":true,\"file\":\"${FILE_BASE}_scaffs.fna\"}" >> ${FILE_BASE}.go

# execute it
${SSPATH}/graph_ops ${FILE_BASE}_asm.json ${FILE_BASE}.go

# create the visualization pdfs
for i in ${FILE_BASE}_asm?.dot; do neato -Tpdf $i > ${i%.*}.pdf; done