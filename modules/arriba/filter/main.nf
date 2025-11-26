process ARRIBAFILTER {
        tag "$smpl_id"
        label "process_low"

        input:  
                tuple val(sampleId), path(real)
                tuple val(sampleId), path(discarded)

        output:
                tuple val(sampleId), path("*.fusions.tsv"), emit: fusions
                path "versions.yml", emit: versions


        script:

        """
        head -n 1 ${real} > header.txt
        filterFusionGene.py --g ${params.fusiongenelist_WTS} --f ${discarded}
        uniq Selected.fusion.tsv > uniq_fusion.tsv
        cat header.txt ${real} uniq_fusion.tsv > ${smpl_id}.fusions.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
                python: \$(python --version 2>&1| sed -e 's/Python //g')
        END_VERSIONS
        """
        stub:
        """
        touch ${sampleId}.fusions.tsv
        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
                python: \$(python --version 2>&1| sed -e 's/Python //g')
        END_VERSIONS
        """
}