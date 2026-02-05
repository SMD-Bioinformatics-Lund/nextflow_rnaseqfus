/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { FUSIONCATCHER } from '../../../modules/fusionCatcher/main.nf'

workflow fusionCatcherWorkflow {
    take:
        referenceFusionCatcher
        fileInfo
        
    main:
        // def input = readNumber.combine(sampleInfo)
        ch_versions = Channel.empty()
        FUSIONCATCHER (referenceFusionCatcher, fileInfo)
        ch_versions = ch_versions.mix(FUSIONCATCHER.out.versions)

    emit:
        fusion = FUSIONCATCHER.out.results
        versions = ch_versions
}