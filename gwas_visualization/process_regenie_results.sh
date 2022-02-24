#This code is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.

#[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this code.

# Concatenate files, assuming all regenie output files are in one directory
zcat assoc.c1_diabetes_cc.regenie.gz | head -1 > assoc.all.regenie
find *.gz  -exec sh -c "zcat {} | tail -n +2 -f " \; >> assoc.all.regenie

# Add `#` to the header (required for LocusZoom)
sed '1 s/./#&/' assoc.all.regenie >  assoc_edit.all.regenie

# Convert file from space to tab-separated
sed 's/ /\t/g' assoc_edit.all.regenie >  multiple_assoc_edit_tab.all.regenie
