// Assuming FASTP and SUBSAMPLE have been modified to emit version information

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
}