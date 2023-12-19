# Application Note: to liftover UKB array genotype data

Yih-Chii Hwang, PhD

### Introduction

[UK Biobank](https://www.ukbiobank.ac.uk/) (UKB) has collected array genotyping, whole exome sequencing (WES), and whole genome sequencing (WGS) for half a million participants aged 40-69 years. In addition to the genetic data, researchers can gain access to thousands of traits/phenotypes of the participants, making UKB one of the richest data sources for performing GWAS. 

Most recent GWAS tools (e.g. [BOLT-LMM](https://alkesgroup.broadinstitute.org/BOLT-LMM/BOLT-LMM_manual.html), [SAIGE](https://github.com/weizhouUMICH/SAIGE), [regenie](https://rgcgithub.github.io/regenie/)) were designed to be applied in 2-steps. The first step accounts for genetic architectures for population stratifications and relatedness by modeling genotype makers, usually with whole genome array genotyping data. The second step utilizes the fitted model and performs association testing with immputed genotypes, WES or WGS data.  

UKB released array genotyping data on GRCh37 reference build ([link](https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=263)), while WES and WGS data are being released on GRCh38 ([link](https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=170), [link](https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=180)). In order to perform association testing with the sequncing data on step-2, it is desirable to get the array genotyping data on the same reference coordinate as the sequencing data. See [comment of regenie's authors](https://github.com/rgcgithub/regenie/issues/82) about lifting over data in the first step.

Since the scale of UKB array genotyping data is large (~800K genome-wide variant markers over ~500K individuals), we will need to better manage the pre-processing, post-processing, and the overall computer resources of this liftover work. This note is describing a processing workflow on how I convert the UKB array genotyping data from GRCh37 to [hs38DH](https://github.com/lh3/bwa/blob/master/bwakit/run-gen-ref#L13) (primary assembly of GRCh38 + ALT contigs + decoy contigs + HLA genes). 

### Tools, liftover pipeline, and resource management

There are many tools available to align and convert coordinates from one build to another. E.g. [CrossMap](http://crossmap.sourceforge.net/), [liftOver](https://genome-store.ucsc.edu/), [Remap](https://www.ncbi.nlm.nih.gov/genome/tools/remap/docs/api), etc. These tools are capable to determine the coordinate in a target genome assembly build (target), according to where it was first determined in another build (source).

I chose `Picard LiftoverVcf` ([link](https://gatk.broadinstitute.org/hc/en-us/articles/360037060932-LiftoverVcf-Picard-)) for converting all ~500K participants’ genotypes to GRCh38. It recovers the scenarios when an ALT allele equals the target's REF allele by swapping REF/ALT variants. This can happen when the allele presentation of PLINK genotype file has different order than REF/ALT, or the variant has considered an ALT in the source build but now considered an REF in the target build. 

The pipeline consits two parts. First, it scatters the job of running `picard LiftoverVcf` for all 26 (autosomal+X+Y+XY+MT) chromosomes. This also includes the pre-processing of converting the PLINK BED/BIM/FAM file sets into VCFs, as `Picard LiftoverVcf` requires VCF input, and the post-processing of coverting the lifted VCFs back to PLINK. Secondly, it gathers and merges all lifted PLINKs, and splitting it into per-chromosome PLINK files. 

For each chromosome, it would take up to 200 GB disk space (around 30x of the original BED file size) for mediating the liftover work. `Picard LiftoverVcf` can be memory intensive for the scale of the sample size, here we designated 50 GB of memory for each chromosome's liftover work. To further optimize the memory resources required for the pipeline, the variant sorting is disabled in `Picard LiftoverVcf` as it is found to be a memory intensive operation. Instead, the pipeline sorts the intermediate lifted VCF using `bcftools sort` before converting it back to PLINK format. 

The entire liftover process and the compute resource requirements for the work are summarized in a [WDL](https://github.com/openwdl) workflow ([liftover_plink_beds.wdl](liftover_plink_beds.wdl)). The workflow utilizes [bcftools](https://github.com/samtools/bcftools), [picard](https://github.com/broadinstitute/picard), [plink](https://www.cog-genomics.org/plink/) and [plink2](https://www.cog-genomics.org/plink/2.0/) and they are wrapped as using this [Dockerfile](docker/Dockerfile) a docker image ([link](https://quay.io/repository/yihchii/liftover_plink_beds)).  

### Results

Of all the 805,426 markers reported in the UKB genome-wide genotyping array, 803,700 (99.79%) were lifted from GRCh37 to GRCh38. For a quick check, I compared the result with an orthogonal data source -- annotations for the Axiom UKB WCSG array on hg38 build. 

There are 707,082 of the 805,426 UKB markers having records in the hg38 annotation file (NetAffx CSV file). Of these, 706,158 markers were lifted to GRCh38 using the liftover workflow presented. We found that 99.98% (705,997 / 706,158) of the lifted markers are consensus with the array’s hg38 annotation. This is suggesting that the liftover pipeline works properly. The rest 161 markers are having discrepancies because of chromosome mismatching (52), position mismatching (23), allele mismatching (60), or missing annotation (26). 

### Usage on UK Biobank Research Analysis Platform (RAP) 

Theoretically the WDL workflow can be executed anywhere with any of the execution engines listed https://github.com/openwdl/wdl#execution-engines. I have only compiled it and tested it on [Research Analysis Platform](https://ukbiobank.dnanexus.com) (RAP) and [DNAnexus Platform](https://platform.dnanexus.com), which uses [dxCompiler](https://github.com/dnanexus/dxCompiler). 

```bash
# Compile the workflow 
$ java -jar <path_to>/dxCompiler-2.4.3.jar compile liftover_plink_beds.wdl -project <project-xxxx>
workflow-yyyy
```

Where the project-xxxx corresponds to the [unique project ID](https://dnanexus.gitbook.io/uk-biobank-rap/getting-started/creating-a-project) of yours on RAP, and workflow-yyyy is the compiled workflow ID for the liftover pipeline.

Once the workflow is compiled, the liftover analysis can be run by feeding the BED/BIM/FAM files along with the corresponding liftover chain file (e.g. [b37ToHg38.over.chain](https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/gnomAD/b37ToHg38.over.chain)) and the target build’s fasta or fasta.gz file (e.g. [1000genomes.grch38.fasta-index.tar.gz](https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=1000), or `GRCh38_full_analysis_set_plus_decoy_hla.fa` under `/Bulk/Exome sequences/Exome OQFE CRAM files/helper_files/` on RAP) by first ensuring a copy of each reference file on the corresponding RAP project. All input parameters can be provided in JSON format (e.g. [liftover_input_template.json](liftover_input_template.json)) . 

```bash
# Execute the compiled workflow on RAP/DNAnexus
$ dx run workflow-yyyy -f input.json --brief -y
analysis-zzzz
```

Alternatively, input parameters can also be specified via the webUI of [RAP](https://ukbiobank.dnanexus.com).

**Runtime/Cost:**\* The liftOver analysis for all 26 chromosomes' PLINK files ([Data-Field 22418](https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=22418)) from GRCh37 to GRCh38 finished within 17.5 hours wall clock time on [RAP](https://ukbiobank.dnanexus.com/landing). With the RAP compute rate, the cost is ~£56.5 with on-demand instances (priority High). If using spot instances (priority Low), the cost can be lowered to ~£10.5.

\* The estimates were generated in April 2021. All numbers can be subject to change. Compute rate could be changing by RAP's Terms of Service. Depending on the instance type of choice, the implementation of the pipeline and more, there is always room for further optimizations on runtime or cost, or both. 

### Acknowledgements

Thanks to Tony Marcketta ([@AMarcketta](https://twitter.com/amarcketta)), Joe Foster, Chiao-Feng Lin ([@chiaofenglin](https://twitter.com/chiaofenglin)), Peter Nguyen, Arkarachai Fungtammasan ([@Chai_Arkarachai](https://twitter.com/Chai_Arkarachai)), and Jason Chin ([@infoecho](https://twitter.com/infoecho)) for the discussions on the liftover process. This is part of our data preparation process for our research project using the UK Biobank Resource under Application Number ‘46926’. We thank all the participants in the UK Biobank study. 

### Disclaimers

Code in this folder is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.

[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this code.
