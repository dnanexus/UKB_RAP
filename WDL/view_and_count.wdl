version 1.0

workflow view_and_count {
 input {
   File cram
   File cram_index
   File ref_fasta
   File ref_fasta_index
   Int? num_chrom = 22
 }

  call slice_cram {
    input :
      cram = cram,
      cram_index = cram_index,
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      num_chrom = num_chrom
  }
  scatter (slice in slice_cram.slices) {
    call count_bam {
      input: bam = slice
    }
  }
  output {
    Array[Int] count = count_bam.count
  }
}


task slice_cram {
  input {
    File cram
    File cram_index
    File ref_fasta
    File ref_fasta_index
    Int? num_chrom = 22
  }

  command <<<
  set -xeo pipefail
  file_prefix=$( basename ~{cram} ".cram")
  samtools view -b -h ~{cram} -T ~{ref_fasta} > ${file_prefix}.bam
  bam_file=${file_prefix}.bam
  samtools index $bam_file
  mkdir slices/
  for i in `seq ~{num_chrom}`; do
    samtools view $bam_file\
      -o slices/$i.bam "chr${i}"
  done

  >>>
  runtime {
    docker: "quay.io/ucsc_cgl/samtools"
  }
  output {
    Array[File] slices = glob("slices/*.bam")
  }
}

task count_bam {
  input {
    File bam
  }

  command <<<
    mkdir out

    samtools view -c ~{bam}

  >>>
  runtime {
    docker: "quay.io/ucsc_cgl/samtools"
  }
  output {
    Int count = read_int(stdout())
  }
}
