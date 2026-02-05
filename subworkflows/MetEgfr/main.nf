/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { MET_EGFR } from '../../modules/exon_skipping/main.nf'

workflow metEgfrWorkflow {
    take:
        bedFile
        starMetrices

    main:
        ch_versions = Channel.empty()
        MET_EGFR ( bedFile, starMetrices )
        ch_versions = ch_versions.mix(MET_EGFR.out.versions)

    emit:
        fusion = MET_EGFR.out.result
        versions = ch_versions
}
