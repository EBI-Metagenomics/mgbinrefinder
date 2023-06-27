include { BINNING_REFINER } from '../modules/binning_refiner'

workflow REFINE {
    take:
        name
        binner1
        binner2
        binner3
    main:
        BINNING_REFINER(name, binner1, binner2, binner3)
    emit:
        refined = BINNING_REFINER.out.refined_bins
}
