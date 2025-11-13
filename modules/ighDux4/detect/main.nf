process IGHDUX4_BREAKPOINT_DETECT {

    tag "$sampleId"
    label 'process_medium'

input:
    tuple val(sampleId), path(bam), path(bai)

output: 
    tuple val(sampleId), path("*.txt"), emit: duxStatus
    path "versions.yml", emit: versions  

script:
"""
IGH_DUX4_breakpoints.pl -bam ${bam} -genome grch38 > ${sampleId}.txt 

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    perl: \$( echo \$(perl -v 2>&1) |sed 's/.*(v//; s/).*//')
END_VERSIONS

"""

// Stub section for simplified testing
stub:
"""
touch ${sampleId}.txt 

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    perl: \$( echo \$(perl -v 2>&1) |sed 's/.*(v//; s/).*//')
END_VERSIONS
"""
}