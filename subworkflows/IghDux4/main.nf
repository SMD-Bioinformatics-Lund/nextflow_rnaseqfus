/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { IGHDUX4_ALIGN } from '../../modules/ighDux4/align/main.nf'
include { SAMTOOLS_SORT} from '../../modules/samtools/sort/main.nf'
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
        ch_versions = Channel.empty()

        IGHDUX4_ALIGN ( starRef, readsInfo )
        ch_versions = ch_versions.mix(IGHDUX4_ALIGN.out.versions) 
        
        SAMTOOLS_SORT ( IGHDUX4_ALIGN.out.dux4Bam )
        ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions) 

        // def samtoolsView = IGHDUX4_ALIGN.out.dux4Bam.combine(SAMTOOLS_SORT.out.sorted_bam)
        SAMTOOLS_VIEW_IGHDUX4 ( ighDux4Bedfile, SAMTOOLS_SORT.out.sorted_bam )
        ch_versions = ch_versions.mix(SAMTOOLS_VIEW_IGHDUX4.out.versions) 
        
        realignBwa = readsInfo.combine(SAMTOOLS_VIEW_IGHDUX4.out.duxreads)

        realignBwa.view()

        REALIGN_BWA (fasta, metaCoyote, realignBwa )
        ch_versions = ch_versions.mix( REALIGN_BWA.out.versions) 


        IGHDUX4_BREAKPOINT_DETECT (REALIGN_BWA.out.realigned_bam)
        ch_versions = ch_versions.mix(IGHDUX4_BREAKPOINT_DETECT.out.versions) 


    emit:
        fusion = IGHDUX4_BREAKPOINT_DETECT.out.duxStatus
        versions = ch_versions
}





