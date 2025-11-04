/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { IGHDUX4_ALIGN } from '../../modules/ighDux4/align/main.nf'
include { SAMTOOLS_INDEX} from '../../modules/samtools/index/main.nf'
include { SAMTOOLS_VIEW_IGHDUX4 } from '../../modules/ighDux4/alignView/main.nf'
include { REALIGN_BWA } from '../../modules/ighDux4/realignBwa/main.nf'
include { IGHDUX4_BREAKPOINT_DETECT } from '../../modules/ighDux4/detect/main.nf'


workflow ighDux4Workflow {
    take:
        starRef
        readsInfo
        ighDux4Bedfile
        fasta
        metaCoyote

    main:
        IGHDUX4_ALIGN ( starRef, readsInfo )
        
        SAMTOOLS_INDEX ( IGHDUX4_ALIGN.out )
        def samtoolsView = IGHDUX4_ALIGN.out.combine(SAMTOOLS_INDEX.out)

        samtoolsView.view()

        SAMTOOLS_VIEW_IGHDUX4 ( ighDux4Bedfile, samtoolsView )
        
        realignBwa = readsInfo.combine(SAMTOOLS_VIEW_IGHDUX4.out)

        realignBwa.view()

        REALIGN_BWA (fasta, metaCoyote, realignBwa )

        IGHDUX4_BREAKPOINT_DETECT (REALIGN_BWA.out)


    emit:
        fusion = IGHDUX4_BREAKPOINT_DETECT.out
}





