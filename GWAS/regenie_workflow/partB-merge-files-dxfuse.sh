#!/bin/sh

# Requirements: 
# Please refer to readme.md for more information about the requirements

# How to Run:
# Run this script using: sh 01-merge-files-dxfuse.sh on the command line

# Inputs
# - /Data/diabetes_wes_200k.phe - not strictly needed, but swiss-army-knife needs at least one input

# Outputs
# - ukb22418_c1_22_v2_merged.bed - used as input for parts C and D
# - ukb22418_c1_22_v2_merged.bim - used as input for parts C and D
# - ukb22418_c1_22_v2_merged.fam - used as input for parts C and D

#cmd to run (use as input with `-icmd=$run_merge`)
run_merge="cp /mnt/project/Bulk/Genotype\ Results/Genotype\ calls/ukb22418_c[1-9]* . ;\
        ls *.bed | sed -e 's/.bed//g'> files_to_merge.txt; \
        plink --merge-list files_to_merge.txt --make-bed\
        --autosome-xy --out ukb22418_c1_22_v2_merged;\
        rm files_to_merge.txt;"

dx run swiss-army-knife -iin="/Data/diabetes_wes_200k.phe" \
   -icmd="${run_merge}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="/Data/" --brief --yes 