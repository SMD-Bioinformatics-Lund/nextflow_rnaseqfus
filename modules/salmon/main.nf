process SALMON {
    tag "${smpl_id}"
    publishDir "${params.outdir}/quant", mode: 'copy'

    cpus 8
    memory 24.GB
    errorStrategy 'ignore'

    input:
        tuple val(smpl_id), path(read1), path(read2)

    output:
        tuple val(smpl_id), path("${smpl_id}.quant.sf")
        tuple val(smpl_id), path("${smpl_id}.flenDist.txt")
        path("versions.yml")

    when:
        params.quant
	
	script:
    """
    salmon quant --threads ${task.cpus} \
        -i ${params.salmon_index_dir} \
        -l A -1 ${read1} -2 ${read2} \
        --validateMappings -o .

    mv ./libParams/flenDist.txt ${smpl_id}.flenDist.txt
    mv quant.sf ${smpl_id}.quant.sf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        salmon: "$( salmon --version | sed 's/salmon //')"
        perl: "$( echo $(perl -v 2>&1) | sed 's/.*(v//; s/).*//' )"
    END_VERSIONS
    """

    stub:
    """
    touch ${smpl_id}.quant.sf
    touch ${smpl_id}.flenDist.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        salmon: "stub_version"
        perl: "\$( echo \$(perl -v 2>&1) | sed 's/.*(v//; s/).*//' )"
    END_VERSIONS
    """
    
}
