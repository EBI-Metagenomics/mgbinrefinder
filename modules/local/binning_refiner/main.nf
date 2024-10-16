process BINNING_REFINER {

    label 'process_low'
    tag "${name} ${meta.id}"

    container 'quay.io/biocontainers/biopython:1.75'

    input:
    val(name)
    tuple val(meta), path(bin1, stageAs: "binner1/*"), path(bin2, stageAs: "binner2/*"), path(bin3, stageAs: "binner3/*")

    output:
    tuple val(meta), path("${meta.id}_output_${name}/refined"), emit: refined_bins
    // versions
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //g'"), topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c 'import pkg_resources; print(pkg_resources.get_distribution(\"biopython\").version)'"), topic: versions

    script:
    """
    binning_refiner.py -1 binner1/* -2 binner2/* -3 binner3/* -o "${meta.id}_output_${name}" -n "${meta.id}_${name}"
    """
}