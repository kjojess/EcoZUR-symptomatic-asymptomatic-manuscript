#!/bin/bash

#use bmtagger to remove human reads from metagenome (methods summarized here: https://www.hmpdacc.org/hmp/doc/HumanSequenceRemoval_SOP.pdf)

#install bmtagger in conda environment
conda create -n bmtagger
conda activate bmtagger
conda install bmtool
conda install srprism

#Download latest human genome from ncbi (https://www.ncbi.nlm.nih.gov/genome/guide/human/)

#use bmtool to make index for bmfilter, output is a binary file generate in reference.bitmask
bmtool -d GRCh38_latest_genomic.fna -o GRCh38_latest_genomic.bitmask -A 0 -w 18

#make index for sprism
srprism mkindex -i GRCh38_latest_genomic.fna -o GRCh38_latest_genomic.srprism -M 7168

#makeblastdb for blastn
makeblastdb -in GRCh38_latest_genomic.fna -dbtype nucl

#run BMtagger
bmtagger.sh -b reference.bitmask -x reference.srprism -T tmp -q0 -1
./bmtagger.sh -b GRCh38_latest_genomic.bitmask -x GRCh38_latest_genomic.srprism -T /tmp/ -q0 -1 /data/data_GATech/EcoZUR/metagenomes/EcoZUR_symp_asymp/E.coli_MAGs/Reads_symp_asymp_E.coli_analysis/MG_24_R1_fastq_gz.CoupledReads.fa -o MG_24_R1_fastq.gz.CoupledReads_filtered.fa -X 

#getting an error here, possibly a problem with sprism?
#try https://sourceforge.net/p/hmscan/discussion/general/thread/a38c690776/?limit=25
#got to work by adding -pass false at line 34 of bmtagger.sh (so it will process as single-end reads)

#then need to filter host reads from samples using enveomics script FastA.filter.pl


