# Run liftover WDL workflow on microarray data

This code is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.

[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this code.

This work was done mainly by Yih-Chii Hwang, PhD as a part of her work on [AD-by-proxy GWAS Guide](https://dnanexus.gitbook.io/uk-biobank-rap/science-corner/gwas-ex).

## Files needed for LiftOver to convert b37 to hg38
### UCSC chain file

`wget https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/gnomAD/b37ToHg38.over.chain`
`dx upload b37ToHg38.over.chain.gz --path <path>`

### RefSeq reference genome sequence

`wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz`

`dx upload hg38.fa.gz --path <path>`

## WDL workflow

Download dxCompiler [here](https://github.com/dnanexus/dxCompiler/releases)

`java -jar <path_to_dxCompliler> compile liftover_plink_beds.wdl -project <project_id>`

## Running workflow

Run this workflow on bed, bim and fam data located in `/Bulk/Genotype Results/Genotype calls/`.

All input parameters can be provided in JSON format, e.g. [liftover_input_template.json](liftover_input_template.json). 

```bash
# Execute the compiled workflow on RAP/DNAnexus
$ dx run workflow-yyyy -f input.json --brief -y
analysis-zzzz
```

Alternatively, input parameters can also be specified via the webUI of [RAP](https://ukbiobank.dnanexus.com).

