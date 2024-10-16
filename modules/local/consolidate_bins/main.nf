process CONSOLIDATE_BINS {

    label 'process_low'
    tag "${meta.id}"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.75':
        'biocontainers/biopython:1.75' }"

    input:
    tuple val(meta),
          path(bins1, stageAs: "binner1"),
          path(bins2, stageAs: "binner2"),
          path(bins3, stageAs: "binner3"),
          path(bins12, stageAs: "binner12"),
          path(bins13, stageAs: "binner13"),
          path(bins23, stageAs: "binner23"),
          path(bins123, stageAs: "binner123")
    tuple val(meta),
          path(stats1, stageAs: "stats/*"),
          path(stats2, stageAs: "stats/*"),
          path(stats3, stageAs: "stats/*"),
          path(stats12, stageAs: "stats/*"),
          path(stats13, stageAs: "stats/*"),
          path(stats23, stageAs: "stats/*"),
          path(stats123, stageAs: "stats/*")

    output:
    tuple val(meta), path("consolidated_bins")        , emit: consolidated_bins
    tuple val(meta), path("consolidated_stats.tsv")   , optional: true, emit: consolidated_stats
    tuple val(meta), path("dereplicated_bins/*")      , optional: true, emit: dereplicated_bins
    tuple val(meta), path("dereplicated_list.tsv")    , optional: true, emit: dereplicated_list
    // versions
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //g'"), topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c 'import pkg_resources; print(pkg_resources.get_distribution(\"biopython\").version)'"), topic: versions
    tuple val("${task.process}"), val('numpy'), eval("python -c 'import pkg_resources; print(pkg_resources.get_distribution(\"numpy\").version)'"), topic: versions
    // logging
    tuple val("${task.process}"), val('binner1'), eval("ls binner1 | wc -l")          , topic: logs
    tuple val("${task.process}"), val('binner2'), eval("ls binner2 | wc -l")          , topic: logs
    tuple val("${task.process}"), val('binner3'), eval("ls binner3 | wc -l")          , topic: logs
    tuple val("${task.process}"), val('binner12'), eval("ls binner12 | wc -l")        , topic: logs
    tuple val("${task.process}"), val('binner23'), eval("ls binner23 | wc -l")        , topic: logs
    tuple val("${task.process}"), val('binner13'), eval("ls binner13 | wc -l")        , topic: logs
    tuple val("${task.process}"), val('binner123'), eval("ls binner123 | wc -l")      , topic: logs
    tuple val("${task.process}"), val('consolidated'), eval("ls consolidated | wc -l"), topic: logs

    script:
    """
    consolidate_bins.py -i binner1 binner2 binner3 binner12 binner13 binner23 binner123 -s stats -v
    """
}