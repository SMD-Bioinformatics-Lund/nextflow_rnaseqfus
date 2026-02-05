include { FILTER_FUSION } from '../../modules/filter/main.nf'

workflow filterFusionWorkflow {
    take:
        aggFusionCalls
        stGenelist

    main:
        ch_versions = Channel.empty()
        // if params.wts == false -> go for the filtering else go for the marking the fusions
        FILTER_FUSION( aggFusionCalls, stGenelist )  
        ch_versions = ch_versions.mix(FILTER_FUSION.out.versions)
    
    emit:
        filtered = FILTER_FUSION.out.filteredfusion
        versions = ch_versions
}
