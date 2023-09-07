#!/usr/bin/env bash

set -euo pipefail
Rscript /usr/bin/buildErrorsN.R \
  --fastqsInDir . \
  --errorsOutDir . \
  --errorsFileNameSuffix err.rds \
  --isPaired $params.isPaired \
  --platform $params.platform \
  --nValue $params.nValue
mkdir filtered
mv *.fastq filtered/
