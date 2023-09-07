#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process downloadFiles {
  container = "veupathdb/corral:latest"

  input:
    val id

  output:
    tuple val(id), path("${id}**.fastq")

  script:
    template 'downloadFiles.bash'
}


process bowtie2 {
  container = "veupathdb/corral:latest"

  label 'align'

  input:
    tuple val(sample), path(readsFastq)

  output:
    tuple val(sample), path("numReads.txt"), path("alignments*.sam")

  script:
    if(params.libraryLayout.toLowerCase() == 'single')
      template 'bowtieSingle.bash'
    else if(params.libraryLayout.toLowerCase() == 'paired')
      template 'bowtiePaired.bash'
}


process alignmentStats {
  container = "veupathdb/corral:latest"

  publishDir "${params.resultDir}/alignmentStats"

  label 'stats'

  input:
    tuple val(sample), path(numReadsPath), path(alignmentsSam)

  output:
    tuple val(sample), path("${sample}.alignmentStats.txt")

  script:
    template 'alignmentStats.bash'
}


process summarizeAlignments{
  container = "veupathdb/corral:latest"

  publishDir "${params.resultDir}/summarizedAlignments"

  label 'postAlign'

  input:
    tuple val(sample), path(numReadsPath), path(alignmentsSam)
    path markerToTaxonTsv

  output:
    path("${sample}.taxa.tsv")

  script:
    template 'summarizeAlignments.bash'
}


process makeTsv {
  container = "veupathdb/corral:latest"

  publishDir params.resultDir, mode: 'move', overwrite: true  

  label 'postAlign'

  input:
    file("*.taxa.tsv")

  output:
    file("${params.summaryColumn}.${params.summaryFormat}.tsv")

  script:
    template 'makeTsv.bash'
}


def postAlign(sample_numReadsPath_alignmentsSam,  markerToTaxonPath) {

  alignmentStats(sample_numReadsPath_alignmentsSam)
  return summarizeAlignments(sample_numReadsPath_alignmentsSam,  markerToTaxonPath)

}


process knead {
  label 'download_and_preprocess'

  container = 'veupathdb/humann'

  input:
    tuple val(id), path(readsFastq)
    val libraryLayout

  output:
    tuple val(id), path("*_*_kneaddata.fastq")

  script:
    template 'knead.bash'
}


process runHumann {
  afterScript 'mv -v reads_humann_temp/reads.log humann.log; test -f reads_humann_temp/reads_metaphlan_bugs_list.tsv && mv -v reads_humann_temp/reads_metaphlan_bugs_list.tsv bugs.tsv ; rm -rv reads_humann_temp'

  container = 'veupathdb/humann'

  input:
    tuple val(sample), path(kneadedReads)

  output:
    path("${sample}.metaphlan.out"), emit: metaphlan_output
    tuple val(sample), file("${sample}.gene_abundance.tsv"), emit: sample_geneabundance_tuple
    path("${sample}.pathway_abundance.tsv"), emit: pathway_abundance
    path("${sample}.pathway_coverage.tsv"), emit: pathway_coverage

  script:
    template 'runHumann.bash'
}


process groupFunctionalUnits {
  container = 'veupathdb/humann'

  input:
    tuple val(sample), file(geneAbundances)
    each (groupType)
    val functionalUnitNames

  output:
    file("${sample}.${groupType}.tsv") 

  script:
    group=params.unirefXX + "_" + groupType
    groupName=functionalUnitNames[groupType]
    template 'groupFunctionalUnits.bash'
}


process aggregateFunctionAbundances {
  container = 'veupathdb/humann'
  
  publishDir params.resultDir, mode: 'move'

  input:
    file('*') 
    each (groupType) 

  output:
    file("${groupType}s.tsv")

  script:
    template 'aggregateFunctionAbundances.bash'
}


process aggregateTaxonAbundances {
  container = 'veupathdb/humann'
  
  publishDir params.resultDir, mode: 'move'

  input:
    file('*') 

  output:
    file("taxon_abundances.tsv")

  script:
    '''
    merge_metaphlan_tables.py *.metaphlan.out \
     | grep -v '^#' \
     | cut -f 1,3- \
     | perl -pe 'if($.==1){s/.metaphlan//g}' \
     > taxon_abundances.tsv
    '''
}


process aggregatePathwayAbundances {
  container = 'veupathdb/humann'
  
  publishDir params.resultDir, mode: 'move'

  input:
    file('*') 

  output:
    file("pathway_abundances.tsv")

  script:
    template 'aggregatePathwayAbundances.bash'
}


process aggregatePathwayCoverages {
  container = 'veupathdb/humann'

  publishDir params.resultDir, mode: 'move'

  input:
    file('*') 

  output:
    file("pathway_coverages.tsv")

  script:
    template 'aggregatePathwayCoverages.bash'
}


workflow metagenomicLocal {

  take:
    sample_reads

  main:

    functionalUnitNames = [
    eggnog: "eggnog",
     go: "go",
    ko: "kegg-orthology",
    level4ec: "ec",
    pfam: "pfam",
    rxn: "metacyc-rxn",
    ]

    sample_numReads_alignments = bowtie2( sample_reads )
    xs = postAlign( sample_numReads_alignments, params.markerToTaxonPath )
    makeTsv(xs.collect())

    kneadedReads = knead(sample_reads, params.libraryLayout.toLowerCase())
    humannOutput = runHumann(kneadedReads)

    taxonAbundances = humannOutput.metaphlan_output.collect()
    aggregateTaxonAbundances(taxonAbundances)

    functionAbundances = groupFunctionalUnits(humannOutput.sample_geneabundance_tuple, params.functionalUnits, functionalUnitNames )
    functionAbundancesCollected = functionAbundances.collect()
    aggregateFunctionAbundances(functionAbundancesCollected, params.functionalUnits)

    pathwayAbundances = humannOutput.pathway_abundance.collect()
    aggregatePathwayAbundances(pathwayAbundances)

    pathwayCoverages = humannOutput.pathway_coverage.collect()
    aggregatePathwayCoverages(pathwayCoverages)
}