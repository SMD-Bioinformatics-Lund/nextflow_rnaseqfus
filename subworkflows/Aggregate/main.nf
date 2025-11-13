include { AGGREGATE_FUSION_PANEL } from '../../modules/aggregatefusion/main.nf'
include { AGGREGATE_FUSION_WTS } from '../../modules/aggregatefusion/main.nf'

workflow aggFusionWorkflow_PANEL {
    take:
    fusionCatcher
    arribaFusion
    starFusion
    exonskip

    main:
    ch_versions = Channel.empty()
    AGGREGATE_FUSION_PANEL(fusionCatcher, arribaFusion, starFusion, exonskip) 
    ch_versions = ch_versions.mix(AGGREGATE_FUSION.out.versions) 
    
    emit:
    aggregate = AGGREGATE_FUSION.PANEL.out.aggregated_vcf
    versions = ch_versions
}

workflow aggFusionWorkflow_WTS {
    take:
    fusionCatcher
    arribaFusion
    starFusion

    main:
    ch_versions = Channel.empty()
    AGGREGATE_FUSION_WTS(fusionCatcher, arribaFusion, starFusion) 
    ch_versions = ch_versions.mix(AGGREGATE_FUSION_WTS.out.versions) 
    
    emit:
    aggregate = AGGREGATE_FUSION_WTS.out.aggregated_vcf
    versions = ch_versions
}