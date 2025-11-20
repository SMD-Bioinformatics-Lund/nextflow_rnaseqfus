process SALMON {
    tag "${smpl_id}"
    label "process_medium"

    input:
        tuple val(smpl_id), path(read1), path(read2)

    output:
        tuple val(smpl_id), path("${smpl_id}.quant.sf"), emit: quant
        tuple val(smpl_id), path("${smpl_id}.flenDist.txt"), emit: flenDist
        path("versions.yml"), emit: versions

   when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        salmon quant --threads ${task.cpus} ${args} -1 ${read1} -2 ${read2} --validateMappings -o ./${smpl_id}

        cp ./${smpl_id}/libParams/flenDist.txt ${smpl_id}.flenDist.txt
        cp ./${smpl_id}/quant.sf ${smpl_id}.quant.sf

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            salmon: \$(salmon --version | sed 's/salmon //')
        END_VERSIONS
        """

    stub:
        """
        touch ${smpl_id}.quant.sf
        touch ${smpl_id}.flenDist.txt
        echo "Parameters : ${task.ext.args ?: ''}" > parameters.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            salmon: \$(salmon --version | sed 's/salmon //')
        END_VERSIONS
        """
}
