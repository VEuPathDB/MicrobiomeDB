#!/usr/bin/env bash

set -euo pipefail

if [ "$libraryLayout" = "paired" ]; then

    ${params.kneaddataCommand} \
        --mateIds_are_equal ${params.mateIds_are_equal} \
        --query_mate_separator ${params.query_mate_separator} \
        --input ${id}_1.fastq \
        --input ${id}_2.fastq \
        --cat-final-output \
        -o .
    
elif [ "$libraryLayout" = "single" ]; then

    ${params.kneaddataCommand} \
        --mateIds_are_equal ${params.mateIds_are_equal} \
        --query_mate_separator ${params.query_mate_separator} \
        --input ${id}.fastq \
        --output . 
    
fi
