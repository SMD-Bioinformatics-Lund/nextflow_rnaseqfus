process COUNT_LINES {
    input:
        tuple val(smpl_id), path (file_to_count)

    output:
        val line_count


    script:
    """
        wc -l $file_to_count | awk '{print \$1}' 
    """
}