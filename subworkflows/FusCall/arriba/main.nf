/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { ARRIBA_ALIGN } from '../../../modules/arriba/align/main.nf'
include { ARRIBA_FUSCALL } from '../../../modules/arriba/FusionCall/main.nf'
include { ARRIBA_FILTER } from '../../../modules/arriba/filter/main.nf'
include { SAMTOOLS_SORT } from '../../../modules/samtools/sort/main.nf'
include { ARRIBA_VISUALIZATION } from '../../../modules/arriba/visualization/main.nf'


workflow arribaWorkflow {
    take:
        starRef
        readsInfo
        fasta
        gtf
        blacklist
        knownFusions
        proteinDomains
        cytobands

    main:
        // def input = readNumber.combine(sampleInfo)
        ch_versions = Channel.empty()
        ARRIBA_ALIGN ( starRef, readsInfo)
        ch_versions = ch_versions.mix(ARRIBA_ALIGN.out.versions)

        ARRIBA_FUSCALL ( ARRIBA_ALIGN.out.bam, fasta, gtf, blacklist,knownFusions, proteinDomains)
        ch_versions = ch_versions.mix(ARRIBA_FUSCALL.out.versions)

        SAMTOOLS_SORT (ARRIBA_ALIGN.out.bam )
        ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions)

        VIS_INPUT = SAMTOOLS_SORT.out.sorted_bam.join(ARRIBA_FUSCALL.out.fusions)

        // SAMTOOLS_SORT.out.sorted_bam.join(ARRIBA_FUSCALL.out.fusions).view()
        ARRIBA_VISUALIZATION (VIS_INPUT,gtf,cytobands, proteinDomains )
        ch_versions = ch_versions.mix(ARRIBA_VISUALIZATION.out.versions)

        if ( params.cdm == "fusion") {
            ARRIBA_FILTER(ARRIBA_FUSCALL.out.fusions, ARRIBA_FUSCALL.out.discarded_fusions)
            ch_versions = ch_versions.mix(ARRIBA_FILTER.out.versions)
        }
        
    emit:
        fusion = params.cdm == "fusion" ? ARRIBA_FILTER.out.fusions :  ARRIBA_FUSCALL.out.fusions
        fusionDiscarded = ARRIBA_FUSCALL.out.discarded_fusions
        bam = SAMTOOLS_SORT.out.sorted_bam
        metrices = ARRIBA_ALIGN.out.logs
        report = ARRIBA_VISUALIZATION.out.visualization
        versions = ch_versions
}