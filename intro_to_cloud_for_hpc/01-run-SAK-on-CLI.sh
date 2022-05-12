#!/bin/bash
export project=`dx pwd`
#Adjust this script for a file of interest - this is a fake file linked here

dx run app-swiss-army-knife \
  -iin="${project}Bulk/Exome sequences/Population level exome OQFE variants, pVCF format/1234567.vcf.gz"
  -icmd='vcftools \
    --gzvcf "1234567.vcf.gz" \
    --minGQ 15 --minDP 10 \
    --recode \
    --out 1234567.filtered'
