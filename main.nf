#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { REFINEMENT } from './workflows/binrefinder'

workflow {
    REFINEMENT ()
}
