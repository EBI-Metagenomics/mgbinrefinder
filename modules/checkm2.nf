process CHECKM2 {

    label 'process_medium'
    //afterScript 'touch ${name}_filtered_genomes'
    errorStrategy =
    {
        if (task.exitStatus == 1) { return 'ignore' }
        else if (task.exitStatus in ((130..145) + 104 + 1)) { return 'retry' }
        else { return 'finish' }
    }
    tag "${name} ${meta.id}"

    container 'quay.io/biocontainers/checkm2:1.0.1--pyh7cba7a3_0'

    input:
    val(name)
    tuple val(meta), path(bins)
    path checkm2_db

    output:
    tuple val(meta), path(bins), path("${name}_all_stats.csv")   , emit: stats
    tuple val(meta), path("${name}_filtered_genomes")    , emit: filtered_genomes
    tuple val(meta), path("${name}_filtered_genomes.tsv"), emit: filtered_stats
    path "versions.yml"                                  , emit: versions

    script:
    """
    mkdir -p bins
    echo "checkm predict"
    checkm2 predict --threads ${task.cpus} \
        --input bins \
        -x fa \
        --output-directory ${name}_checkm_output \
        --database_path ${checkm2_db}

    echo "checkm table"
    echo "genome,completeness,contamination" > ${name}_checkm2.tsv
    tail -n +2 ${name}_checkm_output/quality_report.tsv | cut -f1-3 | tr '\\t' ',' >> ${name}_checkm2.tsv

    awk -F, 'NR == 1 {print; next} {OFS=","; \$1 = \$1 ".fa"; print}' ${name}_checkm2.tsv > ${name}_all_stats.csv

    echo "filter genomes"
    echo "bin\tcompleteness\tcontamination" > ${name}_filtered_genomes.tsv
    cat ${name}_checkm2.tsv | \
        tr ',' '\\t' |\
        grep -v "completeness" |\
        awk '{{if(\$2>=50 && \$2<=100 && \$3>=0 && \$3<=5){{print \$0}}}}' >> ${name}_filtered_genomes.tsv

    echo "choose genomes"
    mkdir -p ${name}_filtered_genomes
    for i in \$(cat ${name}_filtered_genomes.tsv | grep -v "completeness" | cut -f1 ); do
        cp bins/\${i}.* ${name}_filtered_genomes
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: \$(checkm2 --version)
    END_VERSIONS
    """
}