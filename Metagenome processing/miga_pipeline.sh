! usr/bin/bash
#running miga trimming and assembly pipeline https://manual.microbial-genomes.org/part5/workflow

#load modules
module load gcc
module load ruby/2.5.1
module load intel

#new miga project
miga new -P EcoZUR_metagenomes -t metagenomes 
cd EcoZUR_metagenomes

#add data (metagenome read files as compressed fastq files)
miga add -P EcoZUR_metagenomes/ -t metagenome -i raw_reads_paired /path_to_raw_reads/*fastq.gz

#start daemon
miga run -P EcoZUR_metagenomes/ 