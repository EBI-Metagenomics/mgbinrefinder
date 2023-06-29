process RENAME_BINS {

    tag "${bin}"

    input:
    val(name)
    path(bin)

    output:
    path("${name}*"), emit: renamed

    script:
    """
    cp ${bin} ${name}.${bin.baseName}.fa
    """
}

