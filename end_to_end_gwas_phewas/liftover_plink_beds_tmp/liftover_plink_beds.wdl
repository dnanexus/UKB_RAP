###########################################################################################
#                         +------------------------------------------------------------+  
#                         |                                  liftover_plink_beds.wdl   |   
# list of plink files     |     +---------------------+                                |   list of lifted plink sets
# per chromosomes         |   +---------------------+ |    +------------------------+  |   per chromosomes
#                         |  ++-------------------+ | +--->|                        |  |   
# UCSC chain file  -------+->|                    | +----->| merge_and_split_by_chr +--+-> merged plink file set
# (*.chain)               |  | picard_liftovervcf +------->|                        |  |   of chromosome 1-22
#                         |  |                    +-+      +------------------------+  |   
# target reference build  |  +--------------------+                                    |   merged plink file set
# (*.fa.gz)               |                                                            |   of all chromosomes
#                         +------------------------------------------------------------+
# 
###########################################################################################
version 1.0

workflow liftover_plink_beds {
  input {
    Array[File]+ plink_beds
    Array[File]+ plink_bims
    Array[File]+ plink_fams
    File ucsc_chain
    File reference_fastagz
    String split_par_build_code = "hg38"
    Boolean output_autosomal = true
  }
  String reference = basename(basename(basename(reference_fastagz, ".gz"), ".fa"), ".fasta")
  scatter(plink_bed in plink_beds){
    String file_prefix = basename(plink_bed, ".bed")
    call picard_liftovervcf {
      input: 
        plink_bed = plink_bed,
        plink_bims = plink_bims,
        plink_fams = plink_fams,
        ucsc_chain = ucsc_chain,
        file_prefix = file_prefix,
        reference_fastagz = reference_fastagz,
        split_par_build_code = split_par_build_code,
        reference = reference
    }
  }
  call merge_and_split_by_chr {
    input:
      plink_beds = picard_liftovervcf.lifted_plink_bed,
      plink_bims = picard_liftovervcf.lifted_plink_bim,
      plink_fams = picard_liftovervcf.lifted_plink_fam,
      split_par_build_code = split_par_build_code,
      reference = reference,
      output_autosomal = output_autosomal
  }
  output {
    Array[File] merged_plinks = merge_and_split_by_chr.merged_plinks
    Array[File?] autosomal_plinks = merge_and_split_by_chr.autosomal_plinks
    Array[File?] per_chr_plinks = merge_and_split_by_chr.per_chr_plinks
    Array[File?] unplaced_plinks = merge_and_split_by_chr.unplaced_plinks
    Array[File] lifted_vcf = flatten(picard_liftovervcf.lifted_vcf)
  }
  parameter_meta {
    plink_beds: {
        patterns: ["*.bed"]
    }
    plink_bims: {
        patterns: ["*.bim"]
    }
    plink_fams: {
        patterns: ["*.fam"]
    }
    ucsc_chain: {
        patterns: ["*.chain"]
    }
    reference_fastagz: {
        patterns: ["*.fa*.gz", "*.fa", "*.fasta"]
    }
  }
}

task picard_liftovervcf {
  input {
    File plink_bed 
    Array[File]+ plink_bims
    Array[File]+ plink_fams
    File ucsc_chain
    File reference_fastagz
    String split_par_build_code
    String file_prefix
    String reference
  }
  Int disk_space = ceil(size(plink_bed, "GB") * 30)
  command <<<
    set -x -e -o pipefail

    ## Get memory on the machine, use 80% of the memory for each operation
    memTotal=$(head -n1 /proc/meminfo|awk '{print $2}')
    memXmx_m=$(( ${memTotal}*8/10/1024 ))
    memXmx_g=$(( ${memTotal}*8/10/1024/1024 ))

    ## Convert Plink to VCF
    # chromosome codes for PAR1/PAR2 are all saved as chrX
    # `--merge-x` may cause ploidies to be wrong when using directly with exporting VCF,
    # thus we used `--merge-x` + `--sort-vars` + `--make-bpgen`, then `--export vcf`.
    plink_bed_path="~{plink_bed}"
    plink_prefix="${plink_bed_path%.bed}"
    plink2 --bfile "${plink_prefix}" --make-bpgen --out "~{file_prefix}" \
        --merge-x \
        --sort-vars n \
        --threads $(nproc) --memory "${memXmx_m}"
    plink2 --bpfile "~{file_prefix}" --export vcf bgz --out "~{file_prefix}"
    rm -rf ~{file_prefix}.pgen
    rm -rf ~{plink_bed}

    ## Generate reference index, required for picard LiftoverVcf
    java -jar /opt/picard/picard.jar CreateSequenceDictionary -R "~{reference_fastagz}"

    ## Run Liftover
    java -Xmx"${memXmx_g}"g -jar /opt/picard/picard.jar LiftoverVcf \
        -I "~{file_prefix}.vcf.gz" -O "~{file_prefix}_~{reference}.vcf" \
        -R "~{reference_fastagz}" -C "~{ucsc_chain}" \
        --REJECT "~{file_prefix}_~{reference}_rejected.vcf" \
        --RECOVER_SWAPPED_REF_ALT true --DISABLE_SORT true
    rm -rf "~{file_prefix}.vcf.gz"

    ## Sort VCF by coordinate and generate BGZIP VCF using bcftools
    # Sorting in picard Liftover requires large memory at file writing stage
    # --var-sort
    # This is to avoid error thrown by PLINK with VCF with more than one contigs (i.e. splited chromosome) 
    # when/after converting VCF -> PLINK 
    bcftools sort -o "~{file_prefix}_~{reference}.vcf.gz" -O z \
        --max-mem "${memXmx_g}g" \
        "~{file_prefix}_~{reference}.vcf"
    rm -rf "~{file_prefix}_~{reference}.vcf"

    ## Convert VCF back to plink
    # `--indiv-sort` is used to enusre PLINK FAM output order remains as the original FAM, as LiftOverVcf changed sample order
    # `--allow-extra-chr` is used to permit unplaced contigs
    plink2 --vcf "~{file_prefix}_~{reference}.vcf.gz" --make-bed --out "~{file_prefix}_temp" \
        --id-delim "_" --indiv-sort f "${plink_prefix}.fam" \
        --ref-allele force "~{file_prefix}_~{reference}.vcf.gz" 4 3 '#' \
        --alt1-allele force "~{file_prefix}_~{reference}.vcf.gz" 5 3 '#' \
        --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"

    ## Collect father/mother/sex information from the original FAM file
    # If set to split _par, represent the X chromosome's pseudo-autosomal region (PARs) as PAR1/PAR2
    if [ "~split_par_build_code" == "none" ]; then
        plink2 --bfile "~{file_prefix}_temp" --make-bed --out "~{file_prefix}_~{reference}" \
            --fam "${plink_prefix}.fam" --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
    else
        plink2 --bfile "~{file_prefix}_temp" --make-bed --out "~{file_prefix}_~{reference}" \
            --split-par "~{split_par_build_code}" \
            --fam "${plink_prefix}.fam" --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
    fi
    rm -rf "~{file_prefix}_temp.*"

    ## update FAM file with the phenotype column (batch info for UKB Array)
    awk 'BEGIN{OFS="\t";FS = "[ \t\n]+"}FNR==NR{a[$2]=$6;next}{if ($2 in a) print $1,$2,$3,$4,$5,a[$2]}' \
        "${plink_prefix}.fam" "~{file_prefix}_~{reference}.fam" > "~{file_prefix}_~{reference}_temp.fam"
    mv "~{file_prefix}_~{reference}_temp.fam" "~{file_prefix}_~{reference}.fam"

    bcftools sort -o "~{file_prefix}_~{reference}_rejected.vcf.gz" -O z \
        --max-mem "${memXmx_g}g" \
        "~{file_prefix}_~{reference}_rejected.vcf"

  >>>
  output {
    File lifted_plink_bed = "~{file_prefix}_~{reference}.bed"
    File lifted_plink_bim = "~{file_prefix}_~{reference}.bim"
    File lifted_plink_fam = "~{file_prefix}_~{reference}.fam"
    Array[File] lifted_vcf = glob('*.vcf.gz')
  }
  runtime {
    docker: "quay.io/yihchii/liftover_plink_beds:20220104"
    memory: "64 GB"
    disks: "local-disk ~{disk_space} SSD"
  }
}

task merge_and_split_by_chr {
  input {
    Array[File] plink_beds 
    Array[File] plink_bims
    Array[File] plink_fams
    String split_par_build_code
    String reference
    Boolean output_autosomal = true
  }
  Int disk_space = ceil(size(flatten([plink_beds, plink_bims, plink_fams]), "GB") * 3)
  File fam_file = select_first(plink_fams)
  command <<<
    set -x -e -o pipefail
    mkdir -p autosomal_dir/

    cat "~{write_lines(plink_beds)}" | sed -e 's/.bed//g' > files_to_merge.txt
    cat files_to_merge.txt
    ## Get memory on the machine, use 80% of the memory for each operation
    memTotal=$(head -n1 /proc/meminfo|awk '{print $2}')
    memXmx_m=$(( ${memTotal}*8/10/1024 ))
    ## Get one of the fam files as correspondance FAM file for all

    ## Merge all PLINK files into one
    plink --merge-list files_to_merge.txt --make-bed \
      --indiv-sort f "~{fam_file}" \
      --update-sex "~{fam_file}" 3 \
      --out "ukb_~{reference}_merged" \
      --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
    # Fix the FAM file to show also the batch numbers
    awk 'BEGIN{OFS="\t";FS = "[ \t\n]+"}FNR==NR{a[$2]=$6;next}{if ($2 in a) print $1,$2,$3,$4,$5,a[$2]}' \
      "~{fam_file}" "ukb_~{reference}_merged.fam" > "ukb_~{reference}_merged_temp.fam"
    mv "ukb_~{reference}_merged_temp.fam" "ukb_~{reference}_merged.fam"
    # Remove input files to save space
    set +x
    for prefix in $(cat "files_to_merge.txt"); do
        rm -rf ${prefix}.*
    done
    set -x

    if [ "~{output_autosomal}" == "true" ]; then
      ## Get autosomal (chr1-22) PLINK file set
      plink2 --bfile "ukb_~{reference}_merged" --chr 1-22 --make-bed \
        --out "autosomal_dir/ukb_c1-22_~{reference}_merged"  \
        --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
      cp "ukb_~{reference}_merged.fam" "autosomal_dir/ukb_c1-22_~{reference}_merged.fam"
    fi

    ## Split into per-chromosome PLINK file set from the merged PLINK
    for i in $(cut -f1 ukb_~{reference}_merged.bim|sort -u|grep -v 'PAR'||true); do 
      plink2 --bfile "ukb_~{reference}_merged" --chr "${i}" --make-bed \
          --out "ukb_c${i}_~{reference}" \
          --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
      cp "ukb_~{reference}_merged.fam" "ukb_c${i}_~{reference}.fam"
    done

    ## Gererate PAR plink file set if they exist
    par_num=$(cut -f1 ukb_~{reference}_merged.bim|sort -u|grep 'PAR1\|PAR2'|wc -l||true)
    if [ "${par_num}" == "2" ]; then
      plink2 --bfile "ukb_~{reference}_merged" --chr PAR1,PAR2 --make-bed \
        --out "ukb_cPAR_~{reference}" \
        --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
      cp "ukb_~{reference}_merged.fam" "ukb_cPAR_~{reference}.fam"
    fi

    ## Generate plink files containing unplaced contigs
    unplaced_num=$(cut -f1 ukb_~{reference}_merged.bim|sort -u|grep -v 'PAR'|grep -v -e '[0-9]$'|wc -l||true)
    if [ "${unplaced_num}" != "0" ]; then
      plink2 --bfile "ukb_~{reference}_merged" --not-chr 1-22,X,Y,PAR1,PAR2,MT --make-bed \
        --out "ukb_unplaced_~{reference}" \
        --allow-extra-chr --threads $(nproc) --memory "${memXmx_m}"
      cp "ukb_~{reference}_merged.fam" "ukb_unplaced_~{reference}.fam"
    fi
  >>>
  output {
    Array[File] merged_plinks = glob("ukb_~{reference}_merged.*")
    Array[File?] autosomal_plinks = glob("autosomal_dir/ukb_c1-22_~{reference}_merged.*")
    Array[File?] per_chr_plinks = glob("ukb_c*_~{reference}.*")
    Array[File?] unplaced_plinks = glob("ukb_unplaced_~{reference}.*")
  }
  runtime {
    docker: "quay.io/yihchii/liftover_plink_beds:20220104"
    cpu: 8
    memory: "16 GB"
    disks: "local-disk ~{disk_space} SSD"
  }
}
