process COYOTE {
    tag "$sampleId"
    label "process_low"

	input:
		tuple val(sampleId), file(importy)
        tuple val(sample), val(clarityId), val(poolId)

	output:
		path("*.coyote"), emit: coyote_output
	
	script:
        if( importy.size() >= 3 ) {
            id              = "${sampleId}-fusions"
            finaloutdir     = "${params.outdir}/${params.subdir}/finalResults/"
            fus_idx         = importy.findIndexOf{ it =~ 'vcf' }
            qc_idx          = importy.findIndexOf{ it =~ 'rnaseq_QC' }
            goi_quant_idx   = importy.findIndexOf{ it =~ 'salmon.expr' }
            exprs_class_idx = importy.findIndexOf{ it =~ 'expr.classified' }
            agg_vcf         = importy[fus_idx]
            qc_val          = importy[qc_idx]
            goi_quant       = importy[goi_quant_idx]
            exprs_class     = importy[exprs_class_idx]

            // Actual script
            """
            echo "import_fusion_to_coyote.pl \\
                --fusions ${finaloutdir}${agg_vcf} \\
                --qc ${finaloutdir}${qc_val} \\
                --id ${id} \\
                --classification ${finaloutdir}${exprs_class} \\
                --expr ${finaloutdir}${goi_quant} \\
                --group ${params.coyote_group} \\
                --clarity-sample-id ${clarityId} \\
                --clarity-pool-id ${poolId}" > ${id}.coyote
            """
        } else {
            println (importy.size())
            id              = "${sampleId}-fusions"
            finaloutdir     = "${params.outdir}/${params.subdir}/finalResults/"
            fus_idx         = importy.findIndexOf{ it =~ 'vcf' }
            qc_idx          = importy.findIndexOf{ it =~ 'rnaseq_QC' }
            agg_vcf         = importy[fus_idx]
            qc_val          = importy[qc_idx]

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
    
    // Stub section for simplified testing
    stub:
        if( importy.size() >= 3 ) {
            id              = "${sampleId}-fusions"
            finaloutdir     = "${params.outdir}/${params.subdir}/finalResults/"
            fus_idx         = importy.findIndexOf{ it =~ 'vcf' }
            qc_idx          = importy.findIndexOf{ it =~ 'rnaseq_QC' }
            goi_quant_idx   = importy.findIndexOf{ it =~ 'salmon.expr' }
            exprs_class_idx = importy.findIndexOf{ it =~ 'expr.classified' }
            agg_vcf         = importy[fus_idx]
            qc_val          = importy[qc_idx]
            goi_quant       = importy[goi_quant_idx]
            exprs_class     = importy[exprs_class_idx]

            // Actual script
            """
            echo "import_fusion_to_coyote.pl \\
                --fusions ${finaloutdir}${agg_vcf} \\
                --qc ${finaloutdir}${qc_val} \\
                --id ${id} \\
                --classification ${finaloutdir}${exprs_class} \\
                --expr ${finaloutdir}${goi_quant} \\
                --group ${params.coyote_group} \\
                --clarity-sample-id ${clarityId} \\
                --clarity-pool-id ${poolId}" > ${id}.coyote
            """
        } else {
            println (importy.size())
            id              = "${sampleId}-fusions"
            finaloutdir     = "${params.outdir}/${params.subdir}/finalResults/"
            fus_idx         = importy.findIndexOf{ it =~ 'vcf' }
            qc_idx          = importy.findIndexOf{ it =~ 'rnaseq_QC' }
            agg_vcf         = importy[fus_idx]
            qc_val          = importy[qc_idx]

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
}