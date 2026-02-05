process REALIGN_BWA {

    tag "$sampleId"
    label 'process_medium'

    input:
        path fasta
        tuple val(sample), val(lims_id), val(pool_id)
        tuple val(sampleId), path(read1), path(read2), path(ighDux4reads)

    output:
        tuple val(sampleId), path("${lims_id}_IGHDUX4_RNAbwa_n200_hg38.bam"), path("${lims_id}_IGHDUX4_RNAbwa_n200_hg38.bam.bai"), emit: realigned_bam
        path("versions.yml"), emit: versions

    script:
        """
        # Extract subset of reads matching IGHDUX4 target list
        zcat ${read1} | grep -F -A3 -f ${ighDux4reads} --no-group-separator | gzip -c > ${lims_id}_R1_001_ID_n200_grch38.fastq.gz &
        zcat ${read2} | grep -F -A3 -f ${ighDux4reads} --no-group-separator | gzip -c > ${lims_id}_R2_001_ID_n200_grch38.fastq.gz &
        wait

        # Find BWA index prefix
        INDEX=\$(find -L ./ -name "GCA_000001405.15_GRCh38_no_alt_analysis_set_nochr.fna*.amb" | sed 's/.amb//')

        # Alignment and sorting
        bwa mem -M -R "@RG\\tID:IGHDUXreads_${lims_id}\\tSM:${lims_id}" \\
            -t ${task.cpus} \\
            \${INDEX} \\
            ${lims_id}_R1_001_ID_n200_grch38.fastq.gz \\
            ${lims_id}_R2_001_ID_n200_grch38.fastq.gz \\
            2> bwa.log | samblaster 2> samblaster.log | samtools sort \\
            -@ 4 -m 20G -T bwa_dedup_temp -o ${lims_id}_IGHDUX4_RNAbwa_n200_hg38.bam -O bam -

        samtools index ${lims_id}_IGHDUX4_RNAbwa_n200_hg38.bam

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bwa: \$(bwa 2>&1 | grep -Eo 'Version[: ]+[0-9.]+' | head -n1 | awk '{print \$2}')
            samtools: \$(samtools --version | head -n1 | awk '{print \$2}')
            samblaster: \$(samblaster --version 2>&1 | grep -Eo '[0-9.]+')
        END_VERSIONS
        """

    stub:
        """
        # Create dummy BAM and index files
        touch ${lims_id}_IGHDUX4_RNAbwa_n200_hg38.bam
        touch ${lims_id}_IGHDUX4_RNAbwa_n200_hg38.bam.bai

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bwa: "0.7.17"
            samtools: "1.20"
            samblaster: "0.1.26"
        END_VERSIONS
        """
}
