#!/usr/bin/env nextflow
import nextflow.splitter.CsvSplitter
nextflow.enable.dsl=2

def fetchRunAccessions( tsv ) {
    def splitter = new CsvSplitter().options( header:true, sep:'\t' )
    def reader = new BufferedReader( new FileReader( tsv ) )
    splitter.parseHeader( reader )
    List<String> run_accessions = []
    Map<String,String> row
    while( row = splitter.fetchRecord( reader ) ) {
       run_accessions.add( row['run_accession'] )
    }
    return run_accessions
}

//---------------------------------------------------------------
// Include Workflows
//---------------------------------------------------------------

include { metagenomicSRA } from './modules/metagenomicSRA.nf'
include { metagenomicLocal } from './modules/metagenomicLocal.nf'
include { markerGeneAnalysis } from './modules/markerGeneAnalysis.nf'

//---------------------------------------------------------------
// Metagenomic
//---------------------------------------------------------------

workflow metagenomic {

  if(params.downloadMethod.toLowerCase() == 'sra') {
    accessions = fetchRunAccessions(params.inputPath)
  }
  else if (params.downloadMethod.toLowerCase() == 'local') {
    if (params.libraryLayout.toLowerCase() == 'paired') {
      sampleReads = Channel.fromFilePairs(params.inputPath + "/*_{1,2}.fastq")
    }
    else if (params.libraryLayout.toLowerCase() == 'single') {
      sampleReads = Channel.fromPath(params.inputPath + "/*.fastq").map { file -> tuple(file.baseName, [file]) }
    }
    else {
      throw new Exception("Non-valid value for params.libraryLayout")
    }
  }
  
  if(!params.mateIds_are_equal) {
    if(params.downloadMethod.toLowerCase() == 'sra') {
      params.mateIds_are_equal = 'True'
    }
    else if (params.downloadMethod.toLowerCase() == 'local') {
      params.mateIds_are_equal = 'False'
    }
  }
  // Setting Defaults If Parameters Do Not Exist
  if(!params.query_mate_separator) {
    if(params.downloadMethod.toLowerCase() == 'sra') {
      params.query_mate_separator = "."
    }
    else if (params.downloadMethod.toLowerCase() == 'local') {
      params.query_mate_separator = "/"
    }
  }

  if (params.downloadMethod.toLowerCase() == 'sra') {
    metagenomicSRA(accessions)
  }
  else if (params.downloadMethod.toLowerCase() == 'local') {
    metagenomicLocal(sampleReads)
  }
}
  
//---------------------------------------------------------------
// MarkerGeneAnalysis
//---------------------------------------------------------------

workflow markergeneanalysis {

  if(params.studyIdFile) {
    accessions = fetchRunAccessions( params.studyIdFile )
  }
  else {
    throw new Exception("Missing params.studyIdFile")
  }
  markerGeneAnalysis(accessions)
}