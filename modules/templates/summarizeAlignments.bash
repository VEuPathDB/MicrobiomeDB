#!/usr/bin/env bash

set -euo pipefail
${params.summarizeAlignmentsCommand} \
  --input ${alignmentsSam} \
  --refdb-marker-to-taxon-path $markerToTaxonTsv \
  --refdb-format eukprot \
  --output-type taxon_all \
  --num-reads \$(cat ${numReadsPath}) \
  --output ${sample}.taxa.tsv 
