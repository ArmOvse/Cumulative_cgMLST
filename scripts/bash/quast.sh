#!/bin/bash

# Create env first
#conda env create -f quast.yaml

eval "$(conda shell.bash hook)"
conda activate quast

echo  "###########  Quality analysis of assembly by QUAST ###############################"
cd /path/to/your/dir/
IN=./BIGSDB_datasets/all/contigs/fasta/
OUT=./BIGSDB_datasets/all/contigs/fasta/quast/
NAMES=./BIGSDB_datasets/all/contigs/fasta_names.txt

mkdir -p $OUT

for NAME in `awk '{print $1}' $NAMES`
do
echo "#### QUAST for sample :" $NAME
sbatch --mem=2000 --qos=bebp -p bebp -o $OUT$NAME.out -e $OUT$NAME.err -J $NAME  --wrap="quast.py $IN$NAME -o $OUT$NAME -t 1"
done


