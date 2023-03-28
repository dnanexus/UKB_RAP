###########################################################################################
#                        +-----------------------------------+  
#                        |                      bgens_qc.wdl |   
#                        |     +------------+                |
#                        |   +------------+ |    +--------+  |
#                        |  ++----------+ | +--->|        |  |   
# list of bgen files  ---+->|           | +----->| gather +--+-> list variants to keep
# per chromosome         |  |  bgen_qc  +------->|        |  | 
#                        |  |           +-+      +--------+  |   
#                        |  +-----------+                    |
#                        |                                   |
#                        +-----------------------------------+
# 
###########################################################################################
version 1.1

workflow bgens_qc {
  input {
    Array[File]+ geno_bgen_files
    Array[File]+ geno_sample_files
    Boolean ref_first = true
    File? keep_file
    Array[File] extract_files
    String plink2_options = ""
    String output_prefix
  }
  scatter ( i in range(length(geno_bgen_files)) ) {
    String file_prefix = basename(geno_bgen_files[i], ".bgen")
    File? extract_file_i = if length ( extract_files ) >= 1 then extract_files[i] else None
    call bgen_qc {
      input: 
        geno_bgen_file = geno_bgen_files[i],
        geno_sample_file = geno_sample_files[i],
        ref_first = ref_first,
        keep_file = keep_file,
        extract_file = extract_file_i,
        
        plink2_options = plink2_options,
        file_prefix = file_prefix
    } 
  }
  call concat_qc_pass_files {
    input:
      qc_pass_snplists = bgen_qc.qc_pass_snplist,
      qc_mindrem_ids = bgen_qc.mindrem_id,
      output_prefix = output_prefix
  }
  output {
    File concat_qc_pass_snplist = concat_qc_pass_files.concatenated_qc_pass_snplist
    File concat_qc_mindrem_id = concat_qc_pass_files.concatenated_mindrem_id
    Array[File] qc_pass_logs = bgen_qc.qc_pass_log
  }
  parameter_meta {
    geno_bgen_files: {
        patterns: ["*.bgen"]
    }
    geno_sample_files: {
        patterns: ["*.sample"]
    }
  }
}

task bgen_qc {
  input {
    File geno_bgen_file
    File geno_sample_file
    Boolean ref_first = true
    File? keep_file
    File? extract_file
    String plink2_options
    String file_prefix
  }
  Int disk_space = ceil(size(geno_bgen_file, "GB") * 3)
  command <<<
    set -x -e -o pipefail

    ## Get memory on the machine, use 80% of the memory for each operation
    memTotal=$(head -n1 /proc/meminfo|awk '{print $2}')
    memXmx_m=$(( ${memTotal}*8/10/1024 ))
    memXmx_g=$(( ${memTotal}*8/10/1024/1024 ))

    ## Run QC filtering and generate qc_pass sample and snp lists
    plink2 --bgen "~{geno_bgen_file}" \
        ~{if ref_first then "ref-first" else "ref-last"} \
        --sample "~{geno_sample_file}" \
        ~{"--keep " + keep_file} \
        ~{"--extract " + extract_file} \
        --out "~{file_prefix}_qc_pass" \
        ~{plink2_options} \
        --write-snplist --write-samples --no-id-header \
        --threads $(nproc) --memory "${memXmx_m}"
    touch "~{file_prefix}_qc_pass.mindrem.id"
  >>>
  output {
    File qc_pass_snplist = "~{file_prefix}_qc_pass.snplist"
    File qc_pass_id = "~{file_prefix}_qc_pass.id"
    File mindrem_id = "~{file_prefix}_qc_pass.mindrem.id"
    File qc_pass_log = "~{file_prefix}_qc_pass.log"
  }
  runtime {
    docker: "quay.io/biocontainers/plink2:2.00a2.3--h712d239_1"
    cpu: "4"
    disks: "local-disk ~{disk_space} SSD"
  }
  parameter_meta {
    geno_bgen_file: {
        patterns: ["*.bgen"]
    }
    geno_sample_file: {
        patterns: ["*.sample"]
    }
  }
}

task concat_qc_pass_files {
  input {
    Array[File]+ qc_pass_snplists
    Array[File]+ qc_mindrem_ids
    String output_prefix = "concatenated_qc_pass"
  }
  Int disk_space = ceil((size(qc_pass_snplists, "GB") + size(qc_mindrem_ids, "GB") ) * 2)
  command <<<
    set -x -e -o pipefail
    cat ~{sep=" " qc_pass_snplists} | sort -k1,1n > "~{output_prefix}.snplist"
    cat ~{sep=" " qc_mindrem_ids} | sort > "~{output_prefix}.mindrem.id"
  >>>
  output {
    File concatenated_qc_pass_snplist = "~{output_prefix}.snplist"
    File concatenated_mindrem_id = "~{output_prefix}.mindrem.id"
  }
  runtime {
    docker: "ubuntu:xenial-20210611"
    disks: "local-disk ~{disk_space} SSD"
  }
}

