! usr/bin/bash
#create conda environment and install qiime2
conda env create -n qiime2-2019.7
conda install -c qiime2/label/r2019.7 qiime2-2019.7

#load conda environment 
conda activate
conda activate qiime2-2019.7

#cd to new directory with tab seperated manifest file specifying file locations (EcoZUR_manifest_all_format.tsv)
cd ~/16S_EcoZUR_qiime2/symp_asymp

#import data
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path EcoZUR_manifest_all_format.tsv --output-path ./EcoZUR.qza --input-format PairedEndFastqManifestPhred33V2

#View seq counts and quality scores
qiime demux summarize --i-data EcoZUR.qza --o-visualization EcoZUR_demux.qzv

#dada2 denoising (also merges paired reads)
qiime dada2 denoise-paired --i-demultiplexed-seqs EcoZUR.qza --p-trunc-len-f 240 --p-trunc-len-r 240 --p-n-threads 12  --o-table table_EcoZUR.qza --o-representative-sequences rep_set_EcoZUR.qza  --o-denoising-stats stats_EcoZUR.qza

#dada2 stats 
qiime metadata tabulate --m-input-file table_EcoZUR.qza --o-visualization table_EcoZUR.qzv
#feature summary
qiime feature-table summarize --i-table trim_EcoZUR.qza --o-visualization stats_EcoZUR.qza --m-sample-metadata-file EcoZUR_metadata.tsv
#feature counts
qiime feature-table tabulate-seqs --i-data rep_set_EcoZUR.qza --o-visualization rep_set_EcoZUR.qza

#make tree
qiime alignment mafft --i-sequences rep_set_EcoZUR.qza --o-alignment aligned_rep_set_EcoZUR.qza
qiime alignment mask --i-alignment aligned_rep_set_EcoZUR.qza --o-masked-alignment masked_aligned_rep_set_EcoZUR.qza
qiime phylogeny fasttree --i-alignment masked_aligned_rep_set_EcoZUR.qza --o-tree tree_masked_aligned_rep_set_EcoZUR.qza
qiime phylogeny midpoint-root --i-tree tree_masked_aligned_rep_set_EcoZUR.qza --o-rooted-tree rooted_tree_masked_aligned_rep_set_EcoZUR.qza

#diversity core metrics
qiime diversity core-metrics-phylogenetic --i-table table_EcoZUR.qza --i-phylogeny rooted_tree_masked_aligned_rep_set_EcoZUR.qza --p-sampling-depth 10000 --m-metadata-file EcoZUR_meta_updated_pathotypes.tsv --output-dir core-metrics-results_10000

#alpha diversity
#qiime2 test for significance in alpha diversity
qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results_10000/faith_pd_vector.qza --m-metadata-file EcoZUR_meta_updated_pathotypes.tsv --o-visualization core-metrics-results_10000/faith_pd_vector_sig.qzv
qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results_10000/evenness_vector.qza --m-metadata-file EcoZUR_meta_updated_pathotypes.tsv --o-visualization core-metrics-results_10000/evenness_group_sign.qzv
qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results_10000/shannon_vector.qza --m-metadata-file EcoZUR_meta_updated_pathotypes.tsv --o-visualization core-metrics-results_10000/shannon_group_sig.qzv

#alpha rarefaction plots
qiime diversity alpha-rarefaction --i-table table_EcoZUR.qza --i-phylogeny rooted_tree_masked_aligned_rep_set_EcoZUR.qza --p-max-depth 10000 --m-metadata-file EcoZUR_meta_updated_pathotypes.tsv --o-visualization alpha_rarefaction_EcoZUR.qzv

#taxonomy
#extract same region from ref seqs--this is for 515F and 806R (download qiime feature-classifier directory)
qiime feature-classifier extract-reads --i-sequences training-feature-classifiers/85_otus.qza --p-f-primer GTGCCAGCMGCCGCGGTAA --p-r-primer GGACTACHVGGGTWTCTAAT --p-trunc-len 120 --p-min-length 100 --p-max-length 400 --o-reads ref-seqs.qza

#train classifier
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads ref-seqs.qza --i-reference-taxonomy training-feature-classifiers/ref-taxonomy.qza --o-classifier classifier.qza

#test classifier
qiime feature-classifier classify-sklearn --i-classifier classifier.qza --i-reads rep_set_EcoZUR.qza --o-classification taxonomy_EcoZUR.qza

#view taxonomy table
qiime metadata tabulate --m-input-file taxonomy_EcoZUR.qza --o-visualization taxonomy_EcoZUR.qzv

#interactive taxonomic bar plots
qiime taxa barplot --i-table table_EcoZUR.qza --i-taxonomy taxonomy_EcoZUR.qza --m-metadata-file EcoZUR_meta_updated_pathotypes.tsv --o-visualization tax_barplots_EcoZUR.qzv

#copy files needed to create phyloseq object in R to a new directory
mkdir phyloseq
cp table_EcoZUR.qza phyloseq
cp rooted_tree_masked_aligned_rep_set_EcoZUR.qza phyloseq
cp taxonomy_EcoZUR.qza phyloseq
cp EcoZUR_meta_updated_pathotypes.tsv phyloseq
