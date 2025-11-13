process SAMTOOLS_VIEW_IGHDUX4 {

    tag "$sampleId"
    label 'process_medium'

input:
    path (ighDux4Bed)
    tuple val(sampleId), path(bam), path(bai)


output: 
    path("*.txt"), emit: duxreads
    path "versions.yml", emit: versions  

script:
def prefix = "${sampleId}" + "_IGHDUX4_reads_n200_grh38"
println (prefix)

"""
samtools view -L ${ighDux4Bed} ${bam} | cut -f 1 | awk '!x[\$0]++' > ${prefix}.txt 

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    samtools: \$(echo \$(samtools 2>&1) | sed 's/.*Version: //; s/ .*//')
END_VERSIONS    
"""
stub:
def prefix = "${sampleId}" + "_IGHDUX4_reads_n200_grh38"
"""
echo "stub_read_1" > ${prefix}.txt

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    samtools: "1.20"
END_VERSIONS
"""
}