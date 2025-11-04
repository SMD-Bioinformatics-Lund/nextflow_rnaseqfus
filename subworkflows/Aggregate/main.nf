include { AGGREGATE_FUSION } from '../../modules/aggregatefusion/main.nf'

workflow aggFusionWorkflow {
    take:
    fusionCatcher
    arribaFusion
    starFusion
    exonskip

    main:
     ch_versions = Channel.empty()
    AGGREGATE_FUSION(fusionCatcher, arribaFusion, starFusion, exonskip) 
    ch_versions = ch_versions.mix(AGGREGATE_FUSION.out.versions) 
    
    emit:
    aggregate = AGGREGATE_FUSION.out.aggregated_vcf
    versions = ch_versions
}
