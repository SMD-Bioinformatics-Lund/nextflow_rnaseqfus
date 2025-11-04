process IGHDUX4_BREAKPOINT_DETECT {

    tag "$sampleId"
    label 'process_medium'

input:
    tuple val(sampleId), path(bam), path(bai)

output: 
    path("*.txt")

script:
"""
IGH_DUX4_breakpoints.pl -bam ${bam} -genome grch38 > ${sampleId}.txt 
"""
}