#!/usr/bin/env nextflow

/*
* nextflow_ST_pipeline - A nextflow  GMS solid tumor fusion pipeline
*/

/*
* General Paramters 
*/

nextflow.enable.dsl = 2
log.info """\
======================================================================
Solid tumor panel RNA fusion analysis pipeline
======================================================================
outdir                  :       $params.outdir
subdir                  :       $params.subdir
crondir                 :       $params.crondir
csv                     :       $params.csv                
ighstatus               :       $params.customDuxIgh
exon_skipping           :       $params.exon_skipping 
=====================================================================
"""


include { subSampleWorkflow } from './subworkflows/SubSample/main.nf'
include { fusionCatcherWorkflow } from './subworkflows/FusCall/fusionCatcher/main.nf'
include { starFusionWorkflow } from './subworkflows/FusCall/starFusion/main.nf'
include { arribaWorkflow } from './subworkflows/FusCall/arriba/main.nf'
include { metEgfrWorkflow } from './subworkflows/MetEgfr/main.nf'
include { ighDux4Workflow } from './subworkflows/IghDux4/main.nf'
include { aggFusionWorkflow_PANEL } from './subworkflows/Aggregate/main.nf'
include { aggFusionWorkflow_WTS } from './subworkflows/Aggregate/main.nf'
include { quantWorkflow } from './subworkflows/Quant/main.nf'
include { filterFusionWorkflow } from './subworkflows/Filter/main.nf'
include { qcWorkflow } from './subworkflows/AlignQC/main.nf'
include { cdmWorkflow } from './subworkflows/CDM/main.nf'
include { coyoteWorkflow } from './subworkflows/Coyote/main.nf'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/custom/dumpsoftwareversions/main.nf'

Channel
    .fromPath(params.csv)
    .splitCsv(header:true)
    .map{ row -> tuple(row.id, file(row.read1), file(row.read2)) }
    .set { sampleInfo }

Channel
	.fromPath(params.csv)
	.splitCsv(header:true)
	.map{row -> tuple(row.id,row.clarity_sample_id, row.clarity_pool_id)}
    .set { metaCoyote }

Channel
    .fromPath(params.csv)
    .splitCsv(header:true)
    .map{ row -> tuple( row.id, row.read1, row.read2, row.clarity_sample_id, row.clarity_pool_id ) }
    .set { ch_cdm }

ch_outdir = Channel.fromPath(params.outdir)
//ch_outdir.view()

sampleReads = params.subsampling_number
fastaHuman = params.fasta
fastaIndexFile = params.fastaIndex

gtfGencode = params.gtf
refStar = params.refbase
refStarfusion = params.refbase2
refFusioncatcher = params.fusioncatcher

knownfusionsArriba = params.knownfusions
blacklistArriba = params.blacklists
proteinDomainArriba = params.proteinDomains
cytobandArriba = params.cytobands

cronDir = params.crondir
bedRefRseqc = params.ref_rseqc_bed
hg38 = params.hg38_sizes
refBed = params.ref_bed
refBedXY =  params.ref_bedXY

metEgfrBed = params.metEgfr
stGenePanel = params.stgenePanel_file

ighDux4bed = params.ighdux4



 workflow {
    ch_versions = Channel.empty()

    subSampleWorkflow ( sampleReads, sampleInfo  ).set{ ch_subsample }
    ch_versions = ch_versions.mix(ch_subsample.versions) 

    fusionCatcherWorkflow ( refFusioncatcher, ch_subsample.subSample ).set{ ch_fusioncatcher }
    ch_versions = ch_versions.mix(ch_fusioncatcher.versions)

    starFusionWorkflow ( params.pairEnd, refStarfusion,ch_subsample.subSample ).set{ ch_starfusion }
    ch_versions = ch_versions.mix(ch_starfusion.versions)

    arribaWorkflow( refStar, ch_subsample.subSample, fastaHuman, gtfGencode, blacklistArriba,  knownfusionsArriba, proteinDomainArriba, cytobandArriba ).set{ ch_arriba }
    ch_versions = ch_versions.mix(ch_arriba.versions)


    if (params.exon_skipping) {
        metEgfrWorkflow ( metEgfrBed, ch_arriba.metrices ).set{ ch_metEgfr }
        ch_versions = ch_versions.mix(ch_metEgfr.versions)
        aggFusionWorkflow_PANEL ( ch_fusioncatcher.fusion,   
                        ch_arriba.fusion,
                        ch_starfusion.fusion,
                        ch_metEgfr.fusion).set {  ch_fusionsAll }
        ch_versions = ch_versions.mix(ch_fusionsAll.versions)
        filterFusionWorkflow (  ch_fusionsAll.aggregate, 
                            stGenePanel ).set { ch_fusionsFinal }
        ch_versions = ch_versions.mix(ch_fusionsFinal.versions)

    } else if (params.customDuxIgh) {
        ighDux4Workflow ( refStar, ch_subsample.subSample, ighDux4bed, fastaIndexFile,  metaCoyote ).set{ ch_metEgfr }
        ch_versions = ch_versions.mix(ch_metEgfr.versions)
        aggFusionWorkflow_WTS ( ch_fusioncatcher.fusion,   
                    ch_arriba.fusion,
                    ch_starfusion.fusion).set {  ch_fusionsAll }
        ch_versions = ch_versions.mix(ch_fusionsAll.versions)
        quantWorkflow ( ch_subsample.subSample ).set { ch_quant }
        ch_versions = ch_versions.mix(ch_quant.versions)
    }

    qcWorkflow ( ch_subsample.subSample, 
                 bedRefRseqc,
                 hg38,
                 refBed,
                 refBedXY,
                 ch_arriba.metrices ).set{ ch_qc }
    ch_versions = ch_versions.mix(ch_qc.versions)

    ch_cdm_input = ch_cdm.join(ch_qc.QC)
    cdmWorkflow (ch_cdm_input, ch_outdir)

    ch_coyote_fusion = params.exon_skipping ? ch_fusionsFinal.filtered : ch_fusionsAll.aggregate
    coyoteWorkflow (    ch_coyote_fusion,
                        ch_qc.QC,
                        metaCoyote,
                        ch_outdir )
    
    sampleInfo
        .map { id, read1, read2 -> id }
        .set { idOnly }
    
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml'), idOnly ) 
 }