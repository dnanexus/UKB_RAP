#!/bin/bash
# Using $in_name and $in_prefix
# You can use this method to generically run on a single input file
# Using "$in_name"
# And output a file that uses the same prefix:
# "$in_prefix".filtered
# Be very careful with single and double quotes!

export project=`dx pwd`

#This is a fake file - replace with a file of interest in your folder

dx run swiss-army-knife \
	    -iin="${project}Bulk/Exome sequences/Population level exome OQFE variants, pVCF format/1234567.vcf.gz"
      -icmd='vcftools --gzvcf "$in_name" --minGQ 15 --minDP 10 --recode --out "$in_prefix".filtered' \
      --instance-type "mem1_ssd1_v2_x16" \
      -y
