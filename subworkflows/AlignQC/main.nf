/*
Import modules according to the subworkflow of the RNA pipelines
*/
include { STAR_ALIGNMENT                } from '../../modules/star/main.nf'
include { ADD_READ_GROUPS               } from '../../modules/picard/main.nf'
include { MARK_DUPLICATES               } from '../../modules/picard/main.nf'
include { COLLECT_INSERT_SIZE_METRICS   } from '../../modules/picard/main.nf'
include { COLLECT_RNA_SEQ_METRICS       } from '../../modules/picard/main.nf'
include { COLLECT_HSMETRICS             } from '../../modules/picard/main.nf'   
include { INNER_DISTANCE                } from '../../modules/picard/main.nf' 
include { GENEBODY                      } from '../../modules/geneBody/main.nf'
include { PROVIDER                      } from '../../modules/provider/main.nf'
include { DEEPTOOLS                     } from '../../modules/deeptools/main.nf'
include { QCEXTRACT_TWISTFUSION         } from '../../modules/postalnqc/main.nf'
include { QCEXTRACT_GMSV5               } from '../../modules/postalnqc/main.nf'
include { QCEXTRACT_WTS                 } from '../../modules/postalnqc/main.nf'

workflow qcWorkflow {
    take:
        readsInfo
        bed
        hgSize
        ref_bed
        ref_bedXY
        starmetrices
        flendist

    main:
        // def input = readNumber.combine(sampleInfo)
        ch_versions = Channel.empty()

        STAR_ALIGNMENT (readsInfo)
        ch_versions = ch_versions.mix(STAR_ALIGNMENT.out.versions)

        ADD_READ_GROUPS (STAR_ALIGNMENT.out.alignedBam)
        ch_versions = ch_versions.mix(ADD_READ_GROUPS.out.versions)

        MARK_DUPLICATES (ADD_READ_GROUPS.out.rgBam)
        ch_versions = ch_versions.mix(MARK_DUPLICATES.out.versions)

        COLLECT_INSERT_SIZE_METRICS (MARK_DUPLICATES.out.markedBam)
        ch_versions = ch_versions.mix(COLLECT_INSERT_SIZE_METRICS.out.versions)

        INNER_DISTANCE (MARK_DUPLICATES.out.markedBam)
        ch_versions = ch_versions.mix(INNER_DISTANCE.out.versions)

        COLLECT_RNA_SEQ_METRICS (MARK_DUPLICATES.out.markedBam)
        ch_versions = ch_versions.mix(COLLECT_RNA_SEQ_METRICS.out.versions) 

        COLLECT_HSMETRICS (MARK_DUPLICATES.out.markedBam)
        ch_versions = ch_versions.mix(COLLECT_HSMETRICS.out.versions)

        GENEBODY ( MARK_DUPLICATES.out.markedBam, bed, hgSize)
        ch_versions = ch_versions.mix(GENEBODY.out.versions) 

        PROVIDER  ( ref_bed, ref_bedXY, MARK_DUPLICATES.out.markedBam) 
        ch_versions = ch_versions.mix(PROVIDER.out.versions) 

        DEEPTOOLS ( MARK_DUPLICATES.out.markedBam )
        ch_versions = ch_versions.mix(DEEPTOOLS.out.versions)

        if ( params.cdm == "solidRNA_GMSv5") {
            QCEXTRACT_GMSV5 ( starmetrices,
                              PROVIDER.out.genotypes,
                              GENEBODY.out.gene_body_coverage, 
                              DEEPTOOLS.out.fragment_size)
            QC   = QCEXTRACT_GMSV5.out.rnaseq_qc
            ch_versions = ch_versions.mix(QCEXTRACT_GMSV5.out.versions) 
                
        } else if ( params.cdm == "twistrnafusionv1-0")  {
            QCEXTRACT_TWISTFUSION ( starmetrices,
                    PROVIDER.out.genotypes,
                    GENEBODY.out.gene_body_coverage, 
                    INNER_DISTANCE.out.insertStatsRseqc)
            QC = QCEXTRACT_TWISTFUSION.out.rnaseq_qc
            ch_versions = ch_versions.mix(QCEXTRACT_TWISTFUSION.out.versions) 
            
        } else {
            QCEXTRACT_WTS ( starmetrices,
            PROVIDER.out.genotypes,
            GENEBODY.out.gene_body_coverage, 
            flendist)
            QC = QCEXTRACT_WTS.out.rnaseq_qc
            ch_versions = ch_versions.mix(QCEXTRACT_WTS.out.versions)

        }
    emit:
        QC 
        versions = ch_versions
}