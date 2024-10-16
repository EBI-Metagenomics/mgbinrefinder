/*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     Config to store module specific params.
     - publishDir
     - ext arguments
     - prefixes
     ( execution params are in nf_*.config )
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process {
    withName: BINNING_REFINER {
        publishDir = [
            [
                mode: params.publish_dir_mode,
                failOnError: true
            ],
        ]
    }

    withName: CHECKM2 {
        publishDir = [
            [
                path: "${params.outdir}/checkm2",
                mode: params.publish_dir_mode,
                failOnError: true
            ],
        ]
    }

    withName: CONSOLIDATE_BINS {
        publishDir = [
            [
                path: "${params.outdir}/",
                mode: params.publish_dir_mode,
                failOnError: true
            ],
        ]
    }
}