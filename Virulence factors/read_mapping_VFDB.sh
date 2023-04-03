#! usr/bin/bash
#mapping shotgun metagenome reads to multifasta of virulence genes from the Virulence Factor Database http://www.mgc.ac.cn/VFs/
#output is a matrix of virulence gene sequencing depths in shotgun metagenomes

#install and activate conda environment
conda create -n VFDB
conda activate VFDB
conda install -c bioconda blast

#download VFDB core dataset fasta and remove white space from fasta headers
sed '/^>/{s/ /_/g}' <VFDB_setA_nt.fas >VFDB_setA_nt_no_spaces.fas

#create database
makeblastdb -in VFDB_setA_nt_no_spaces.fas -dbtype nucl

#blastn metagenome reads against database
for i in $(ls *.CoupledReads.fa); do blastn -query $i -out $(basename $i .CoupledReads.fa).out -num_threads 32 -db VFDB_setA_nt_no_spaces.fas -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen'; done

#filter blast output by >= 90% Identity + 70% query length coverage of predicted protein
for i in $(ls *.out); do cat $i | awk '$3 >= 90 && $4/$13 >=0.7 {print $0}' >> $i.filtered ; done

#filter blast output by best match using enveomics script BlastTab.best_hit_sorted.pl http://enve-omics.ce.gatech.edu/enveomics/docs?t=BlastTab.best_hit_sorted.pl
for i in $(ls *.out.filtered); do sort $i | ../BlastTab.best_hit_sorted.pl > $(basename $i .out.filtered).bh; done

#calculate coverage using enveomics script BlastTab.seqdepth_ZIP.pl http://enve-omics.ce.gatech.edu/enveomics/docs?t=BlastTab.seqdepth_ZIP.pl
for i in $(ls *.bh); do cat $i | ../BlastTab.seqdepth_ZIP.pl ../EcoZUR_MGs_ORFs_all_rep_no_spaces.fas > $(basename $i .bh.out).cov; done

#filter blast.bh.out by ZIP (Zero-inflation (CMME pi)) <= 0.3
for i in $(ls *.cov); do awk '(NR==1) || ($3 <= 0.3 ) ' $i > $(basename $i .cov).ZIPfil ; done

#generate files with two columns (Gene-ID and estimated Coverage)
for i in $(ls *.ZIPfil); do cut -f 1,2 $i > $(basename $i .ZIPfil).tab; done

#Use enveomics script merge.table.pl to create a matrix http://enve-omics.ce.gatech.edu/enveomics/docs?t=Table.merge.pl
../Table.merge.pl *.tab > matrix.txt

#Note: normalize VFDB gene sequncing depths with Microbe Census genome equivalents for relative abundances
