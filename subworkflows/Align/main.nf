/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { STAR_ALIGN } from '../../modules/star/main.nf'
include { STAR_INDEX } from '../../modules/samtools/index/main.nf'

workflow alignStar {
    take:
        index
        gtf
        readsInfo
    main:
        // def input = readNumber.combine(sampleInfo)
        STAR_ALIGNMENT (index, gtf, readsInfo)
        SAMTOOLS_INDEX (STAR_ALIGNMENT.out[0])

    emit:
        bam = STAR_ALIGNMENT.out[0]
        bai = SAMTOOLS_INDEX.out
        metrics = STAR_ALIGNMENT.out[1]
}