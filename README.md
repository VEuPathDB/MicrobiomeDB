# <p align=center>MicrobiomeDB</p>
### <p align=center>Turnkey nextflow workflow for Metagenomic and MarkerGeneAnalysis of microbiome data. Blending of CORRAL, humann and DADA2 workflows.</p>
## ***<p align=center>markergeneanalysis (-entry markergeneanalysis) </p>***  
``` mermaid
flowchart TD
    p0((Channel.fromList))
    p1[markergeneanalysis:markerGeneAnalysis:downloadFiles]
    p2[markergeneanalysis:markerGeneAnalysis:filterFastqs]
    p3[markergeneanalysis:markerGeneAnalysis:buildErrors]
    p4[markergeneanalysis:markerGeneAnalysis:fastqToAsv]
    p5[markergeneanalysis:markerGeneAnalysis:mergeAsvsAndAssignToOtus]
    p6(( ))
    p7(( ))
    p8(( ))
    p0 -->|ids| p1
    p1 --> p2
    p2 --> p3
    p3 --> p4
    p4 --> p5
    p5 --> p8
    p5 --> p7
    p5 --> p6
```
## ***<p align=center>metagenomic (-entry metagenomic) </p>*** 
``` mermaid
flowchart TD
    p0((Channel.fromList))
    p1[metagenomic:metagenomicSRA:downloadFiles]
    p2[metagenomic:metagenomicSRA:bowtie2]
    p3[metagenomic:metagenomicSRA:alignmentStats]
    p4(( ))
    p5(( ))
    p6[metagenomic:metagenomicSRA:summarizeAlignments]
    p7([collect])
    p8[metagenomic:metagenomicSRA:makeTsv]
    p9(( ))
    p10(( ))
    p11[metagenomic:metagenomicSRA:knead]
    p12[metagenomic:metagenomicSRA:runHumann]
    p13([collect])
    p14[metagenomic:metagenomicSRA:aggregateTaxonAbundances]
    p15(( ))
    p16(( ))
    p17(( ))
    p18[metagenomic:metagenomicSRA:groupFunctionalUnits]
    p19([collect])
    p20(( ))
    p21[metagenomic:metagenomicSRA:aggregateFunctionAbundances]
    p22(( ))
    p23([collect])
    p24[metagenomic:metagenomicSRA:aggregatePathwayAbundances]
    p25(( ))
    p26([collect])
    p27[metagenomic:metagenomicSRA:aggregatePathwayCoverages]
    p28(( ))
    p0 -->|ids| p1
    p1 --> p2
    p2 --> p3
    p3 --> p4
    p2 --> p6
    p5 -->|markerToTaxonTsv| p6
    p6 --> p7
    p7 --> p8
    p8 --> p9
    p1 --> p11
    p10 -->|libraryLayout| p11
    p11 --> p12
    p12 --> p13
    p12 --> p18
    p12 --> p23
    p12 --> p26
    p13 -->|taxonAbundances| p14
    p14 --> p15
    p16 --> p18
    p17 -->|functionalUnitNames| p18
    p18 --> p19
    p19 -->|functionAbundancesCollected| p21
    p20 --> p21
    p21 --> p22
    p23 -->|pathwayAbundances| p24
    p24 --> p25
    p26 -->|pathwayCoverages| p27
    p27 --> p28
```
