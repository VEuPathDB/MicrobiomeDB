# <p align=center>MicrobiomeDB</p>
### <p align=center>Turnkey nextflow workflow for Metagenomic and MarkerGeneAnalysis of microbiome data. Blending of CORRAL, humann and DADA2 workflows.</p>
***<p align=center>markergeneanalysis</p>***  
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
