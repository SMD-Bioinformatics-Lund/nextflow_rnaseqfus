process COYOTE {
    tag "$sampleId"
    label "process_low"

	input:
		tuple val(sampleId), path(agg_vcf)
        tuple val(sampleId2), path(qc_val)
        tuple val(sample), val(clarityId), val(poolId)
        val(outdir)

	output:
		path("*.coyote"), emit: coyote_output
	
	script:
		def id = "${sampleId}-fusions"
		def finaloutdir = "${params.outdir}/${params.subdir}/finalResults/"


        // Actual script
        """
        echo "import_fusion_to_coyote.pl \\
            --fusions ${finaloutdir}${agg_vcf} \\
            --qc ${finaloutdir}${qc_val} \\
            --id ${id} \\
            --group ${params.coyote_group} \\
            --clarity-sample-id ${clarityId} \\
            --clarity-pool-id ${poolId}" > ${id}.coyote
        """

        // Stub section for simplified testing
        stub:
    	
        def id = "${sampleId}-fusions"
		def finaloutdir = "${params.outdir}/${params.subdir}/finalResults/"

        """
        echo "import_fusion_to_coyote.pl \\
            --fusions ${finaloutdir}${agg_vcf} \\
            --qc ${finaloutdir}${qc_val} \\
            --id ${id} \\
            --group ${params.coyote_group} \\
            --clarity-sample-id ${clarityId} \\
            --clarity-pool-id ${poolId}" > ${id}.coyote
        """
}
