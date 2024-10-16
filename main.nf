#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
nextflow.preview.topic = true

include { REFINEMENT } from './workflows/binrefinder'

workflow {
    REFINEMENT ()
}
