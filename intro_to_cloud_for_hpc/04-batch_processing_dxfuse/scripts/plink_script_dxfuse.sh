#!/usr/bin/bash
# This script should be in the /scripts/ folder in your project.
# Run PLINK in Swiss Army Knife on Worker on each chromosome
# Submit triplet pairs
plink --bfile "/mnt/project/Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 300k release/ukb23145_c${1}_b0_v1"  \
      --geno 0.01  \
      --maf 0.01 \
      --mind 0.02 \
      --hwe 1e-50 midp \
      --make-bed  \
      --out chr"${1}".results
