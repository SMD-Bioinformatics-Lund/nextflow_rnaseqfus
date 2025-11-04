process CDM_REGISTER {
    tag "$sample"
    label "process_low"
    
    input:
        tuple val(sample), val(r1), val(r2) ,val(clarity_id), val(pool_id), path(qc)
        val (output)
    
    output:
        tuple val(sample), file("${sample}.cdm"), emit: cdm_done
        
    script:
        parts = r1.toString().split('/')
        parts.println()
        idx = parts.findIndexOf { it ==~ /......_......_...._........../ }
        rundir = parts[0..idx].join("/")

        """
        echo "--run-folder ${rundir} --sample-id ${sample} --assay ${params.cdm} --qc ${output}/${params.subdir}/finalResults/${qc}" > ${sample}.cdm
        """
    	
    stub:
    	parts = r1.toString().split('/')
    	idx = parts.findIndexOf { it ==~ /......_......_...._........../ }
    	rundir = parts[0..idx].join("/")

        """
        echo "--run-folder ${rundir} --sample-id ${sample} --assay ${params.cdm} --qc ${output}/${params.subdir}/finalResults/${qc}" > ${sample}.cdm
        """
       
}
