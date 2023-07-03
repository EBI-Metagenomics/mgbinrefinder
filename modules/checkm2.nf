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
    path("${name}.checkm2.tsv"), emit: checkm2_results_tsv
    path("${name}_filtered_genomes"), optional: true, emit: checkm2_results_filtered
    path("${name}_filtered_genomes.tsv"), optional: true, emit: checkm2_results_filtered_stats

    script:
    """
    echo "checkm predict"
    checkm2 predict --threads ${task.cpus} --input ${bins} -x fa --output-directory ${name}_checkm_output

    echo "checkm table"
    echo "genome,completeness,contamination" > ${name}.checkm2.tsv
    tail -n +2 ${name}_checkm_output/quality_report.tsv | cut -f1-3 | tr '\\t' ','  >> ${name}.checkm2.tsv

    echo "filter genomes"
    echo "bin\tcompleteness\tcontamination" > ${name}_filtered_genomes.tsv
    cat ${name}.checkm2.tsv | \
        tr ',' '\\t' |\
        grep -v "completeness" |\
        awk '{{if(\$2>=70 && \$2<=100 && \$3>=0 && \$3<=10){{print \$0}}}}' >> ${name}_filtered_genomes.tsv

    echo "choose genomes"
    mkdir -p ${name}_filtered_genomes
    for i in \$(cat ${name}_filtered_genomes.tsv | grep -v "completeness" | cut -f1 ); do
        cp \${i}* ${name}_filtered_genomes
    done
    """
}