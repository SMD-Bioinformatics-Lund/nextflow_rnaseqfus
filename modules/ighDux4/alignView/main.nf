process SAMTOOLS_VIEW_IGHDUX4 {

    tag "$sampleId"
    label 'process_medium'

input:
    path (ighDux4Bed)
    tuple val(sampleId), path(bam), path(bai)


output: 
    path("*.txt")

script:
def prefix = "${sampleId}" + "_IGHDUX4_reads_n200_grh38"
println (prefix)

"""
samtools view -L ${ighDux4Bed} ${bam} | cut -f 1 | awk '!x[\$0]++' > ${prefix}.txt 
"""

}