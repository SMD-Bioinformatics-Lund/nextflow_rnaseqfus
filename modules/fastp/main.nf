process FASTP_NO_UMI {
    tag "$sampleId"
    label "process_medium"

    input:
        tuple val(sampleId), path(r1), path(r2)

    output:
        tuple val(sampleId), path("*.trimmed.R1.fq.gz"), path("*.trimmed.R2.fq.gz"), emit: fq
        tuple val(sampleId), path("*.fastp.json"), path("*.fastp.html"), emit: report
        path "versions.yml", emit: versions

    script:
    """
    fastp -i ${r1} -I ${r2} \\
        -o ${sampleId}.trimmed.R1.fq.gz -O ${sampleId}.trimmed.R2.fq.gz \\
        -j ${sampleId}.fastp.json -h ${sampleId}.fastp.html -w ${task.cpus} --detect_adapter_for_pe -l 30

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version | sed 's/fastp //')
    END_VERSIONS
    """
    
    stub:
    """
    touch ${sampleId}.trimmed.R1.fq.gz ${sampleId}.trimmed.R2.fq.gz
    touch ${sampleId}.fastp.json ${sampleId}.fastp.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version | sed 's/fastp //')
    END_VERSIONS
    """
}

process CONVERT_FASTQ_TO_BAM {
    tag "$sampleId"
    label "process_medium"

    input:
        tuple val(sampleId), path(r1), path(r2)

    output:
        tuple val(sampleId), path("${sampleId}.unaligned.bam"), emit: unaligned_bam
        path "versions.yml", emit: versions

    script:
    """
    java -Xmx4g -jar /usr/picard/picard.jar FastqToSam \\
        F1=$r1 \\
        F2=$r2 \\
        O=${sampleId}.unaligned.bam \\
        SM=$sampleId \\
        LB=lib1 \\
        PL=ILLUMINA \\
        PU=${sampleId}_PU

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard FastqToSam: \$(java -jar /usr/picard/picard.jar FastqToSam --version | sed 's/Version://')
    END_VERSIONS
    """

    stub:
    """
    touch ${sampleId}.unaligned.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard FastqToSam: \$(java -jar /usr/picard/picard.jar FastqToSam --version | sed 's/Version://')
    END_VERSIONS
    """
}

process EXTRACT_UMI {
    tag "$sampleId"
    label "process_medium"

    input:
        tuple val(sampleId), path(bam)

    output:
        tuple val(sampleId), path("${sampleId}.umi_trimmed.bam"), emit: trimmed_bam
        path "versions.yml", emit: versions

    script:
    """
    fgbio ExtractUmisFromBam \\
        --input=$bam \\
        --output=${sampleId}.umi_trimmed.bam \\
        --read-structure=5M2S+T 5M2S+T \\
        --molecular-index-tags=ZA ZB \\
        --single-tag=RX

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio --version | sed 's/fgbio //')
    END_VERSIONS
    """

    stub:
    """
    touch ${sampleId}.umi_trimmed.bam
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio --version | sed 's/fgbio //')
    END_VERSIONS
    """
}

process BAM_TO_FASTQ {
    tag "$sampleId"
    label "process_medium"

    input:
        tuple val(sampleId), path(bam)

    output:
        tuple val(sampleId), path("${sampleId}_R1.fastq.gz"), path("${sampleId}_R2.fastq.gz"), emit: umi_fq
        path "versions.yml", emit: versions

    script:
    """
    java -Xmx4g -jar /usr/picard/picard.jar SamToFastq \\
        I=$bam \\
        F=${sampleId}_R1.fastq \\
        F2=${sampleId}_R2.fastq \\
        INTERLEAVE=false
    gzip ${sampleId}_R1.fastq
    gzip ${sampleId}_R2.fastq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard SamToFastq: \$(java -jar /usr/picard/picard.jar SamToFastq --version | sed 's/Version://')
    END_VERSIONS
    """

    stub:
    """
    touch ${sampleId}_R1.fastq.gz ${sampleId}_R2.fastq.gz
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard SamToFastq: \$(java -jar /usr/picard/picard.jar SamToFastq --version | sed 's/Version://')
    END_VERSIONS
    """
}

process FASTP_POST_UMI {
    tag "$sampleId"
    label "process_medium"

    input:
        tuple val(sampleId), path(r1), path(r2)

    output:
        tuple val(sampleId), path("*.trimmed.R1.fq.gz"), path("*.trimmed.R2.fq.gz"), emit: fq
        tuple val(sampleId), path("*.json"), path("*.html"), emit: report
        path "versions.yml", emit: versions

    script:
    """
    fastp \\
        -i $r1 -I $r2 \\
        -o ${sampleId}.trimmed.R1.fq.gz -O ${sampleId}.trimmed.R2.fq.gz \\
        -j ${sampleId}_post_fastp.json -h ${sampleId}_post_fastp.html \\
        --detect_adapter_for_pe \\
        -w 16

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version | sed 's/fastp //')
    END_VERSIONS
    """

    stub:
    """
    touch ${sampleId}.trimmed.R1.fq.gz ${sampleId}.trimmed.R2.fq.gz
    touch ${sampleId}_post_fastp.json ${sampleId}_post_fastp.html

        cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version | sed 's/fastp //')
    END_VERSIONS
    """
}




/* workflow FASTP {
    take:
        fileInfo

    main:
        if (params.umi) {
            FASTP_NO_UMI(fileInfo)
            CONVERT_FASTQ_TO_BAM(FASTP_NO_UMI.out.fq)
            EXTRACT_UMI(CONVERT_FASTQ_TO_BAM.out.unaligned_bam)
            BAM_TO_FASTQ(EXTRACT_UMI.out.trimmed_bam)
            FASTP_POST_UMI(BAM_TO_FASTQ.out.umi_fq)

            fq_out       = FASTP_POST_UMI.out.fq
            report_out   = FASTP_POST_UMI.out.report
            version_out  = FASTP_POST_UMI.out.versions
        } else {
            FASTP_NO_UMI(fileInfo)
            fq_out       = FASTP_NO_UMI.out.fq
            report_out   = FASTP_NO_UMI.out.report
            version_out  = FASTP_NO_UMI.out.versions
        }

    emit:
        fq       = fq_out
        report   = report_out
        versions = version_out
} */