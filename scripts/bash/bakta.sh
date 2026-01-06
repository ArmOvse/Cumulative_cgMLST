#!/bin/bash

# Create env first
#conda env create -f bakta.yaml

eval "$(conda shell.bash hook)"
conda activate bakta

cpus=1

#Documentation
#https://bakta.readthedocs.io/en/latest/BAKTA.html

cd /path/to/your/dir/Centaur_project/Klebsiella/KpI/chewBBACA_LIN4/

mkdir -p ./bakta/

#Database download
#bakta_db download --output ./bakta/database
#In case you want to update an existing database:
#bakta_db update --db <existing-db-path> [--tmp-dir <tmp-directory>]


echo  "###########  BAKTA for new cgMLST KpI loci ###############################"

IN=./Allele_sequences_95/fasta_short/ # all the fasta file from the short subdirectory of the sche,a dir of CreateSchema
OUT=./Allele_sequences_95/bakta_results/
NAMES=./ExtractCgMLST/ExtractCgMLST/cgMLSTschema95.txt #name of the cgMLST95 loci

mkdir -p $OUT

for NAME in `awk '{print $1}' $NAMES`
do
echo "#### Bakta for sample :" $NAME
sbatch -c $cpus --qos=bebp -p bebp \
-o $OUT$NAME.out \
-e $OUT$NAME.err \
--wrap="bakta \
--db ./bakta/database/db \
--prefix KpI_cgMLST_new \
--output $OUT$NAME \
--prodigal-tf /pasteur/zeus/projets/p01/Klebsiella-ngs/ArmenOvsepian/Centaur_project/Klebsiella/prodigal/Klebsiella_pneumoniae.trn \
--threads $cpus \
--genus Klebsiella \
--species 'pneumoniae' \
--verbose \
--force \
$IN$NAME'_short.fasta' \
"

done