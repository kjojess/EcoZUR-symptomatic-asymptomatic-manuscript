#! usr/bin/bash
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
for f in *.fa; do  bmtagger.sh -b GRCh38_latest_genomic.bitmask -x GRCh38_latest_genomic.srprism -T ~/scratch -q0 -1 $f -o $f.human_reads_removed.fa -X; done

#also used to remove E. coli reads for some analyses by replacing human genomome file with E. coli reference genome

