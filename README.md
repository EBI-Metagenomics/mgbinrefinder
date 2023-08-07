# mgbinrefinder

Quick and efficient Nextflow bin refinement tool.

Scripts and ideas were taken from [metaWRAP](https://github.com/bxlab/metaWRAP)

Improvements:
- python scripts were optimised and re-writen to python3
   - [consolidate_two_sets_of_bins.py](bin%2Fmetawrap%2Fconsolidate_two_sets_of_bins.py) and [dereplicate_contigs_in_bins.py](bin%2Fmetawrap%2Fdereplicate_contigs_in_bins.py) scripts were united into [consolidate_bins.py](bin%2Fconsolidate_bins.py)
- bash wrapper replaced with nextflow
- checkm v1 replaced with checkm v2
- checkm steps are running in parallel

# Installation
- [Nextflow](https://www.nextflow.io/)
- [conda](https://docs.conda.io/en/latest/)
- [checkm2](https://github.com/chklovski/CheckM2) 

```commandline
# activate nextflow env
# clone repo
git clone https://github.com/EBI-Metagenomics/mgbinrefinder.git
# create env
conda create -n mgbinrefinder
conda activate mgbinrefinder
# install reqs
pip3 install requirements.txt
```

# How to run
Input: 3 folders with binning results (*.fa files in each). For example, `bins1`, `bins2`, `bins3`
```commandline
nextflow run main.nf \
    --binner1 bins1 \
    --binner2 bins2 \
    --binner3 bins3
```

### Consolidate bins
Script `consolidate_bins.py` can be run in order to compare results of checkm v1 and checkm v2

```commandline
# stats folder has files binsA.stats, binsB.stats, ...

python3 consolidate_bins.py \
    -i binsA binsB binsC binsAB binsBC binsAC binsABC \
    -s stats
```

### Memory and CPU

<TODO some stats of memory and cpu> 