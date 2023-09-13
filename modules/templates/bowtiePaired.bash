#!/usr/bin/env bash

grep -c '^@' ${sample}_1.fastq > numReads.txt
${params.bowtie2Command} \
  -x /corralDatabase/${databaseRootName} \
  -1 ${sample}_1.fastq \
  -2 ${sample}_2.fastq \
  -S alignmentsPaired.sam
