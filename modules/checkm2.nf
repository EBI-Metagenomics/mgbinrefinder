process CHECKM2 {

    tag "${name}"

    publishDir(
        path: "${params.outdir}/checkm2",
        mode: 'copy',
        failOnError: true
    )

    input:
    val(name)
    path(bins)
    path checkm_db

    output:
    tuple val(name), path(bins), path("${name}.checkm2.tsv"), emit: checkm2_results
    tuple val(name), path("filtered_genomes/*"), path("${name}.filtered_genomes.tsv"), emit: checkm2_results_filtered

    script:
    """
    echo "checkm predict"
    checkm2 predict --threads ${task.cpus} --input ${bins} -x fa --output-directory ${name}_checkm_output

    echo "checkm table"
    echo "genome,completeness,contamination" > ${name}.checkm2.tsv
    tail -n +2 ${name}_checkm_output/quality_report.tsv | cut -f1-3 | tr '\\t' ',' | sed 's/\\,/\\.fa\\,/' >> ${name}.checkm2.tsv

    cat ${name}.checkm2.tsv | \
        tr ',' '\t' |\
        grep -v "completeness" |\
        awk '{{if(\$2>=70 && \$2<=100 && \$3>=0 && \$3<=10){{print \$0}}}}' > ${name}.filtered_genomes.tsv

    mkdir -p filtered_genomes
    for i in \$(cat ${name}.filtered_genomes.tsv); do
        cp \${i}* filtered_genomes
    done
    """
}