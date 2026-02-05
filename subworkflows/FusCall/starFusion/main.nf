/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { STARFUSION_FUSCALL } from '../../../modules/starfusion/main.nf'

workflow starFusionWorkflow {
    take:
        pairEnd 
        starRef
        readsInfo

    main:
        ch_versions = Channel.empty()
        if (pairEnd) {
            STARFUSION_FUSCALL ( starRef, readsInfo)
            ch_versions = ch_versions.mix(STARFUSION_FUSCALL.out.versions)
        }
    emit:
        fusion = STARFUSION_FUSCALL.out.results
        versions = ch_versions

}