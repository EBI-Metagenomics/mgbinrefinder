#!/usr/bin/env python3
# coding=utf-8

import argparse
import os
import sys
from Bio import SeqIO
from shutil import copy

def get_stats(binner, stats):
    stats_dict = {}
    stats_file = None
    for item in os.listdir(stats):
        if binner in item:
            stats_file = item
            break
    if not stats_file:
        print('get_stats: No stats file. Exit')
        sys.exit(1)
    print(f'get_stats: Process {stats_file}')
    with open(os.path.join(stats, stats_file)) as file_in:
        next(file_in)
        for line in file_in:
            line = line.strip().split('\t')
            stats_dict[line[0]] = [float(line[1]), float(line[2])]
    return stats_dict

def get_bins_from_binner(binner_dir):
    binner_dict = {}
    for bin_name in os.listdir(binner_dir):
        bin_path = os.path.join(binner_dir, bin_name)
        binner_dict[bin_name] = {}
        print(f'get_bins_from_binner: Add {bin_path}')
        with open(bin_path) as file_in:
            for record in SeqIO.parse(file_in, "fasta"):
                binner_dict[bin_name][record.id] = len(record.seq)
    return binner_dict


def process_pair(binner1, binner2, stats_path, bins_2_stats):
    if not binner2:
        print(f'--> Add {binner1}')
        return get_bins_from_binner(binner1), get_stats(binner1, stats_path)
    else:
        print(f'--> Add {binner1}')
        bins1 = get_bins_from_binner(binner1)
        bins2 = binner2
        all_bin_pairs = {}
        for bin_1 in bins1:
            all_bin_pairs[bin_1] = {}
            for bin_2 in bins2:
                # find idential contigs between bin_1 and bin_2
                match_1_length, match_2_length, mismatch_1_length, mismatch_2_length = [0 for _ in range(4)]
                for contig in bins1[bin_1]:
                    if contig in bins2[bin_2]:
                        match_1_length += bins2[bin_2][contig]
                    else:
                        mismatch_1_length += bins1[bin_1][contig]
                for contig in bins2[bin_2]:
                    if contig in bins1[bin_1]:
                        match_2_length += bins1[bin_1][contig]
                    else:
                        mismatch_2_length += bins2[bin_2][contig]
            # chose the highest % ID, dependinsh of which bin is a subset of the other
            ratio_1 = 100 * match_1_length / (match_1_length + mismatch_1_length)
            ratio_2 = 100 * match_2_length / (match_2_length + mismatch_2_length)
            if max([ratio_1, ratio_2]) >= 80:
                all_bin_pairs[bin_1][bin_2] = max([ratio_1, ratio_2])
            else:
                all_bin_pairs.pop(bin_1)
        if not all_bin_pairs:
            print('No ratios > 80')
            return bins2, bins_2_stats
        print('all', all_bin_pairs)
        # choose bins
        best_bins, best_bins_stats, best_bins_contigs = {}, {}, {}
        bins_2_matches = []

        bins_1_stats = get_stats(binner1, stats_path)
        for bin_1 in all_bin_pairs:
            score = bins_1_stats[bin_1][0] - bins_1_stats[bin_1][1] * 5
            current_bin = bin_1
            current_contigs = bins1[bin_1]
            current_stats = bins_1_stats[bin_1]

            for bin_2 in all_bin_pairs[bin_1]:
                # check for sufficient overlap (80% bin length)
                bins_2_matches.append(bin_2)
                # check if this bin is better than original
                if (bins_2_stats[bin_2][0] - bins_2_stats[bin_2][1] * 5) > score:
                    current_bin = bin_2
                    current_contigs = bins2[bin_2]
                    current_stats = bins_2_stats[bin_2]
            best_bins_contigs[current_bin] = current_contigs
            best_bins_stats[current_bin] = current_stats

        # retrieve bins from second group that were not found in first group
        untouched_bins2 = list(set(bins_2_stats.keys()).difference(set(bins_2_matches)))
        for bin_2 in untouched_bins2:
            best_bins_stats[bin_2] = bins_2_stats[bin_2]
            best_bins_contigs[bin_2] = bins2[bin_2]
        return best_bins_contigs, best_bins_stats


def parse_args():
    parser = argparse.ArgumentParser(description='The script creates a file that matches ERZ and read accessions')
    parser.add_argument('-i', '--input', required=True, nargs='+', help='Folders with bins')
    parser.add_argument('-s', '--stats', required=True, help='Folders with checkm stats')
    return parser.parse_args()


def main(args):
    consolidated_bins = "consolidated_bins"
    binners = args.input
    if len(binners) < 2:
        print('Number of binners is less then 2. Check you input')
        sys.exit(1)
    else:
        print(f'---> Processing {len(binners)} input binners')
        best_bins, best_stats = {}, {}
        for binner in binners:
            bins, stats = process_pair(binner, best_bins, args.stats, best_stats)
            best_bins = bins
            best_stats = stats
            print('best', bins, best_stats)

    # consolidate folder and stats
    if not os.path.exists(consolidated_bins):
        os.mkdir(consolidated_bins)
    for bin in best_bins:
        for binner in binners:
            if bin in os.listdir(binner):
                copy(os.path.join(binner, bin), os.path.join(consolidated_bins, bin))
                break

    # generate dereplicated bins
    #contig_mapping = {}
    #for bin in os.listdir(consolidated_bins):


    with open("consolidated_stats.tsv", 'w') as file_out:
        file_out.write("\t".join(['bin', 'completeness', 'contamination']) + '\n')
        for item in best_stats:
            file_out.write("\t".join([item, str(best_stats[item][0]), str(best_stats[item][1])]) + '\n')


if __name__ == '__main__':
    args = parse_args()
    main(args)