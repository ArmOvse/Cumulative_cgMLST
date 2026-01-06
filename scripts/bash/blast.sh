#!/bin/bash

# Create env first
#conda env create -f blast.yaml

eval "$(conda shell.bash hook)"
conda activate blast

# This script is made to identify loci that are similar with existing BIGSdb loci  
# All alleles of the new loci identified by chewbbaca (cgMLST95) vs the allele 1 of all BIGSdb loci

cd /your/path/Centaur_project/Klebsiella/
cpus=1


########### Create a blastable BIGSdb loci database (allele 1 from each locus)
all_BIGSdb_allele_1=./Alleles/klebsiella_all_alleles/klebsiella_all_alleles_only_allele_1.fa
mkdir -p ./Alleles/klebsiella_all_alleles/all_BIGSdb_allele_DBs/
mkdir -p ./Alleles/klebsiella_all_alleles/all_BIGSdb_allele_DBs/all_BIGSdb_allele_1_db/
OUT=./Alleles/klebsiella_all_alleles/all_BIGSdb_allele_DBs/all_BIGSdb_allele_1_db/

sbatch -c $cpus --qos=bebp -p bebp \
-o $OUT'makeblastdb_all_BIGSdb_allele_1.out' \
-e $OUT'makeblastdb_all_BIGSdb_allele_1.err' \
--wrap="makeblastdb \
-in $all_BIGSdb_allele_1 \
-dbtype nucl \
-out $OUT'all_BIGSdb_allele_1_db/' \
"

############ blastn between all alleles of new loci and the blastable database with all BIGSdb loci (allele 1)
IN=./KpI/chewBBACA_LIN4/Allele_sequences_95/fasta/ # fasta with all the alleles of loci included in cgMLST95 taken from the schema dir of chewbbaca 
OUT=./Alleles/klebsiella_all_alleles/BLAST_results_all_chewBBACA_alleles_VS_bigsdb_allele_1_default/
NAMES=./KpI/chewBBACA_LIN4/ExtractCgMLST/ExtractCgMLST/cgMLSTschema95.txt #name of the cgMLST95 loci

mkdir -p $OUT

for NAME in `awk '{print $1}' $NAMES`
do

sbatch -c $cpus --qos=bebp -p bebp \
-o $OUT$NAME'.out' \
-e $OUT$NAME'.err' \
--wrap="blastn \
-query $IN$NAME'.fasta' \
-perc_identity 80 \
-outfmt 6 \
-db ./Alleles/klebsiella_all_alleles/all_BIGSdb_allele_DBs/all_BIGSdb_allele_1_db/all_BIGSdb_allele_1_db \
-out $OUT$NAME \
-num_threads $cpus \
"

done