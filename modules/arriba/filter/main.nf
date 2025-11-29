process ARRIBA_FILTER {
        tag "$smpl_id"
        label "process_low"

        input:  
                tuple val(sampleId), path(highconfidence)
                tuple val(sampleId), path(discarded)

        output:
                tuple val(sampleId), path("*.hc.rescued.fusions.tsv"), emit: fusions
                path "versions.yml", emit: versions


        script:
        def args = task.ext.args ?: ''

        """
        head -n 1 ${highconfidence} > header.txt
        filter_fusion_arriba_gene.py ${args} --f ${discarded}
        uniq Selected.fusion.tsv > uniq_fusion.tsv
        cat header.txt ${highconfidence} uniq_fusion.tsv > ${sampleId}.hc.rescued.fusions.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
                python: \$(python --version 2>&1| åsed -e 's/Python //g')
        END_VERSIONS
        """
        stub:
        """
        touch ${sampleId}.hc.rescued.fusions.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
                python: \$(python --version 2>&1| sed -e 's/Python //g')
        END_VERSIONS
        """
}