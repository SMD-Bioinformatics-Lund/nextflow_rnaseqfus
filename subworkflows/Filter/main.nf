include { FILTER_FUSION } from '../../modules/filter/main.nf'

workflow filterFusionWorkflow {
    take:
        aggFusionCalls
        stGenelist

    main:
        ch_versions = Channel.empty()
        FILTER_FUSION( aggFusionCalls, stGenelist )  
        ch_versions = ch_versions.mix(FILTER_FUSION.out.versions)
    
    emit:
        filtered = FILTER_FUSION.out.filteredfusion
        versions = ch_versions
}
