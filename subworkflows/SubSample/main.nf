include { FASTP_NO_UMI } from '../../modules/fastp/main.nf' 
include { CONVERT_FASTQ_TO_BAM } from '../../modules/fastp/main.nf'
include { EXTRACT_UMI } from '../../modules/fastp/main.nf'
include { BAM_TO_FASTQ } from '../../modules/fastp/main.nf'
include { FASTP_POST_UMI } from '../../modules/fastp/main.nf' 
include { SUBSAMPLE } from '../../modules/subsample/main.nf'

workflow subSampleWorkflow {
    take:
        sampleReads
        fileInfo

    main:

    // Dummy file for when fastp is skipped
    ch_empty_report = Channel.value( file("$projectDir/assets/empty.fastp.json") )

    ch_versions = Channel.empty()

    // -------------------
    // Decide which FASTQ and which fastp report to use
    // -------------------
    if (params.umi && params.fastp) {
        // -------- UMI + TRIM: full pipeline --------
        FASTP_NO_UMI(fileInfo)
        ch_versions = ch_versions.mix(FASTP_NO_UMI.out.versions)

        CONVERT_FASTQ_TO_BAM(FASTP_NO_UMI.out.fq)
        ch_versions = ch_versions.mix(CONVERT_FASTQ_TO_BAM.out.versions)

        EXTRACT_UMI(CONVERT_FASTQ_TO_BAM.out.unaligned_bam)
        ch_versions = ch_versions.mix(EXTRACT_UMI.out.versions)

        BAM_TO_FASTQ(EXTRACT_UMI.out.trimmed_bam)
        ch_versions = ch_versions.mix(BAM_TO_FASTQ.out.versions)

        FASTP_POST_UMI(BAM_TO_FASTQ.out.umi_fq)
        ch_versions = ch_versions.mix(FASTP_POST_UMI.out.versions)

        ch_fq            = FASTP_POST_UMI.out.fq
        ch_fastp_report  = FASTP_POST_UMI.out.report

    } else if (params.umi && !params.fastp) {
        // -------- UMI + NO TRIM: minimal fastp --------
        FASTP_NO_UMI(fileInfo)
        ch_versions = ch_versions.mix(FASTP_NO_UMI.out.versions)

        ch_fq           = FASTP_NO_UMI.out.fq
        ch_fastp_report = FASTP_NO_UMI.out.report

    } else if (!params.umi && params.fastp) {
        // -------- NO UMI + TRIM: simple fastp --------
        FASTP_NO_UMI(fileInfo)
        ch_versions = ch_versions.mix(FASTP_NO_UMI.out.versions)

        ch_fq           = FASTP_NO_UMI.out.fq
        ch_fastp_report = FASTP_NO_UMI.out.report

    } else {
        // -------- NO UMI + NO TRIM: no fastp --------
        ch_fq           = fileInfo
        ch_fastp_report = ch_empty_report
    }

    // -------------------
    // Final subsample (always run)
    // -------------------
    SUBSAMPLE(sampleReads, ch_fq)
    ch_versions = ch_versions.mix(SUBSAMPLE.out.versions)

    emit:
        fastpMetrics = ch_fastp_report
        subSample    = SUBSAMPLE.out.sample
        versions     = ch_versions
}









/* // Assuming FASTP and SUBSAMPLE have been modified to emit version information

include { FASTP_NO_UMI          } from '../../modules/fastp/main.nf'
include { CONVERT_FASTQ_TO_BAM  } from '../../modules/fastp/main.nf'
include { EXTRACT_UMI           } from '../../modules/fastp/main.nf'
include { BAM_TO_FASTQ          } from '../../modules/fastp/main.nf'
include { FASTP_POST_UMI        } from '../../modules/fastp/main.nf'
include { SUBSAMPLE } from '../../modules/subsample/main.nf'

workflow subSampleWorkflow {
    take:
        sampleReads
        fileInfo
    
    main:
      if (params.umi) {
        
        ch_versions = Channel.empty()
        FASTP_NO_UMI(fileInfo)
        
        CONVERT_FASTQ_TO_BAM(FASTP_NO_UMI.out.fq)
        ch_versions = ch_versions.mix(CONVERT_FASTQ_TO_BAM.out.versions)

        EXTRACT_UMI(CONVERT_FASTQ_TO_BAM.out.unaligned_bam)
        ch_versions = ch_versions.mix(EXTRACT_UMI.out.versions)
        
        BAM_TO_FASTQ(EXTRACT_UMI.out.trimmed_bam)
        ch_versions = ch_versions.mix(BAM_TO_FASTQ.out.versions)
        
        FASTP_POST_UMI(BAM_TO_FASTQ.out.umi_fq)
        ch_versions = ch_versions.mix(FASTP_POST_UMI.out.versions)
        
        SUBSAMPLE (sampleReads, FASTP_POST_UMI.out.fq)
        ch_versions = ch_versions.mix(SUBSAMPLE.out.versions)   

        
      } else {
        
        ch_versions = Channel.empty()

        FASTP_NO_UMI (fileInfo)
        ch_versions = ch_versions.mix(FASTP_NO_UMI.out.versions)

        SUBSAMPLE (sampleReads, FASTP_NO_UMI.out.fq)
        ch_versions = ch_versions.mix(SUBSAMPLE.out.versions)
      }
        
    emit:
        fastpMetrics = params.umi ? FASTP_POST_UMI.out.report : FASTP_NO_UMI.out.report
        subSample = SUBSAMPLE.out.sample
        // Combine version information from FASTP and SUBSAMPLE into one channel
        versions = ch_versions
} */