#!/bin/bash

# Create env first
#conda env create -f chewie.yaml

eval "$(conda shell.bash hook)"
conda activate chewie

cd /path/to/your/dir/Centaur_project/Klebsiella/KpI/


# The K. pneumoniae reference genome used for prodigal training is:
# https://github.com/B-UMMI/chewBBACA/blob/master/CHEWBBACA/prodigal_training_files/README.md
# https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000240185.1/
# Genome assembly ASM24018v2  NCBI RefSeq assembly GCF_000240185.1


# update blast in miniconda3
#conda config --add channels bioconda
#conda config --add channels conda-forge

IN=./fasta/LIN4 # fasta file of all the genome assemblies to be used for the scheme creation
mkdir -p ./chewBBACA_LIN4

cpus=32


#################################################### CreateSchema   ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/CreateSchema

sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/CreateSchema/CreateSchema.out \
-e ./chewBBACA_LIN4/CreateSchema/CreateSchema.err \
--wrap="chewBBACA.py CreateSchema \
-i $IN \
--n schema \
-o ./chewBBACA_LIN4/CreateSchema/CreateSchema \
--blast-score-ratio 0.6 \
--minimum-length 0 \
--size-threshold 0.2 \
--ptf ../prodigal/Klebsiella_pneumoniae.trn \
--cpu $cpus"

#################################################### AlleleCall ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/AlleleCall

sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/AlleleCall/AlleleCall.out \
-e ./chewBBACA_LIN4/AlleleCall/AlleleCall.err \
--wrap="chewBBACA.py AlleleCall \
-i $IN \
-g ./chewBBACA_LIN4/CreateSchema/CreateSchema/schema \
-o ./chewBBACA_LIN4/AlleleCall/AlleleCall \
--blast-score-ratio 0.6 \
--size-threshold 0.2 \
--cpu $cpus"

#################################################### RemoveGenes ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/RemoveGenes
mkdir -p ./chewBBACA_LIN4/RemoveGenes/RemoveGenes
sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/RemoveGenes/RemoveGenes.out \
-e ./chewBBACA_LIN4/RemoveGenes/RemoveGenes.err \
--wrap="chewBBACA.py RemoveGenes \
-i ./chewBBACA_LIN4/AlleleCall/AlleleCall/results_alleles.tsv \
-g ./chewBBACA_LIN4/AlleleCall/AlleleCall/paralogous_counts.tsv \
-o ./chewBBACA_LIN4/RemoveGenes/RemoveGenes/WithoutParalogous.tsv"

#################################################### ExtractCgMLST ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/ExtractCgMLST
sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/ExtractCgMLST/ExtractCgMLST.out \
-e ./chewBBACA_LIN4/ExtractCgMLST/ExtractCgMLST.err \
--wrap="chewBBACA.py ExtractCgMLST \
-i ./chewBBACA_LIN4/RemoveGenes/RemoveGenes/WithoutParalogous.tsv \
-o ./chewBBACA_LIN4/ExtractCgMLST/ExtractCgMLST"

#################################################### Rerun AlleleCall with 95%cgMLST loci ###################################################################################################################################
sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/AlleleCall/AlleleCall_95.out \
-e ./chewBBACA_LIN4/AlleleCall/AlleleCall_95.err \
--wrap="chewBBACA.py AlleleCall \
-i $IN \
--gl ./chewBBACA_LIN4/ExtractCgMLST/ExtractCgMLST/cgMLSTschema95.txt \
--blast-score-ratio 0.6 \
--size-threshold 0.2 \
-g ./chewBBACA_LIN4/CreateSchema/CreateSchema/schema \
-o ./chewBBACA_LIN4/AlleleCall/AlleleCall_95 \
--cpu $cpus"

#################################################### AlleleCallEvaluator cgMLST loci ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/AlleleCallEvaluator
sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/AlleleCallEvaluator/AlleleCallEvaluator.out \
-e ./chewBBACA_LIN4/AlleleCallEvaluator/AlleleCallEvaluator.err \
--wrap="chewBBACA.py AlleleCallEvaluator \
-i ./chewBBACA_LIN4/AlleleCall/AlleleCall \
-g ./chewBBACA_LIN4/CreateSchema/CreateSchema/schema \
-o ./chewBBACA_LIN4/AlleleCallEvaluator/AlleleCallEvaluator \
--cpu $cpus"

#################################################### AlleleCallEvaluator 95%cgMLST loci ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/AlleleCallEvaluator
sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/AlleleCallEvaluator/AlleleCallEvaluator_95.out \
-e ./chewBBACA_LIN4/AlleleCallEvaluator/AlleleCallEvaluator_95.err \
--wrap="chewBBACA.py AlleleCallEvaluator \
-i ./chewBBACA_LIN4/AlleleCall/AlleleCall_95 \
-g ./chewBBACA_LIN4/CreateSchema/CreateSchema/schema \
-o ./chewBBACA_LIN4/AlleleCallEvaluator/AlleleCallEvaluator_95 \
--cpu $cpus"

##################################################### SchemaEvaluator 95%cgMLST loci ###################################################################################################################################
mkdir -p ./chewBBACA_LIN4/SchemaEvaluator
sbatch -c $cpus --qos=bebp -p bebp \
-o ./chewBBACA_LIN4/SchemaEvaluator/SchemaEvaluator_95.out \
-e ./chewBBACA_LIN4/SchemaEvaluator/SchemaEvaluator_95.err \
--wrap="chewBBACA.py SchemaEvaluator  \
-g ./chewBBACA_LIN4/CreateSchema/CreateSchema/schema \
-o ./chewBBACA_LIN4/SchemaEvaluator/SchemaEvaluator_95/ \
--gl ./chewBBACA_LIN4/ExtractCgMLST/ExtractCgMLST/cgMLSTschema95.txt \
--loci-reports \
--cpu $cpus"
