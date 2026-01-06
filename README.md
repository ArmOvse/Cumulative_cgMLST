
🚀 Introduction

This repository contains all the scripts used for the development of core genome MLST schemes for _Klebsiella_ _pneumoniae_ _sensu_ _stricto_  and two of its sublineages SL147 and SL307.

All data processing and figure generation operations can be found in the scripts/jupyter_notebooks (Jupyter notebooks).

Bash scripts for running third-party tools (QUAST, chewBBACA, BLAST, Bakta) are in scripts/bash.


📥 Main Inputs
- Metadata files: Excel files (.xlsx) from the BIGSdb-Pasteur database, containing: id, name, phylogroup, LIN code, etc.
- Genome assemblies: FASTA files corresponding to the isolates.



📤 Output
- A list of cgMLST loci to be used in the scheme development, and their evaluation metrics.


🛠️ Main Steps of the Pipeline
1. Quality Control (QC)

Check assembly quality using quast (quast.sh in scripts/bash).

Select isolates passing QC for cgMLST scheme development.


2. Scheme Development

Develop core genome MLST scheme using chewBBACA (chewbbaca.sh in scripts/bash).

Select loci present in ≥95% of genomes (cgMLST95 threshold).

Remove loci with high frequency (≥1%) of non-informative paralogous hits (NIPH, NIPHEM during allele calling).


3. Removal of loci that match existing loci in BIGSdb-Pasteur

Identify and exclude loci matching existing BIGSdb-Pasteur loci (≥80% identity and coverage) 
using BLAST (blast.sh in scripts/bash).


4. Test loci in BIGSdb

Define most frequent alleles as type alleles, test them in BIGSdb.

Remove loci with low allele call rate (≤90%) in tested isolates.

Remaining loci form the new cgMLST scheme.


5. Testing of the scheme with validation datasets.              