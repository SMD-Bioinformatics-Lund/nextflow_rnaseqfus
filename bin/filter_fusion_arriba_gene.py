#!/usr/bin/env python

import re
import os
import argparse

###############################################################################
# 1. Parse gene list supporting:
#    - GENE
#    - GENE1::GENE2
#    - GENE1::x  (wildcard partner)
###############################################################################
def load_gene_list(gene_list_file):
    FilePath = os.path.abspath(gene_list_file)
    fusion_rules = []

    try:
        with open(FilePath) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                fusion_rules.append(line)
        return fusion_rules

    except FileNotFoundError:
        print(f"[ERROR] Gene list file not found: {FilePath}")
        exit(1)



###############################################################################
# 2. Check if a gene pair matches ANY rule in the gene list
###############################################################################
def fusion_matches(g1, g2, rules):

    for rule in rules:

        # Case 1: Single gene → match if either gene1 or gene2 contains it
        if "::" not in rule:
            if g1 == rule or g2 == rule:
                return True
            continue

        # Case 2: Pair rule GENE1::GENE2 with possible wildcard x
        r1, r2 = rule.split("::")

        # wildcard handling
        r1 = ".*" if r1.lower() == "x" else r1
        r2 = ".*" if r2.lower() == "x" else r2

        regex = re.compile(rf"^{r1}$")
        regex2 = re.compile(rf"^{r2}$")

        if regex.match(g1) and regex2.match(g2):
            return True

    return False



###############################################################################
# 3. Process arriba TSV and write matching rows
###############################################################################
def filter_fusions(gene_rules, arriba_file):

    FilePath = os.path.abspath(arriba_file)

    try:
        infile = open(FilePath)
    except FileNotFoundError:
        print(f"[ERROR] Fusion file not found: {FilePath}")
        exit(1)

    out = open("Selected.fusion.tsv", "w")

    # Write header untouched
    header = infile.readline()
    out.write(header)

    for line in infile:
        cols = line.rstrip("\n").split("\t")

        gene1 = cols[0]
        gene2 = cols[1]
        annotation1 = cols[6]
        annotation2 = cols[7]
        confidence = cols[14]

        # Only keep non-intronic
        if annotation1 == "intron" or annotation2 == "intron":
            continue

        # Keep high/medium automatically
        if confidence in ("high", "medium"):
            out.write(line)
            continue

        # Otherwise, low confidence must match gene rules
        if confidence == "low":
            if fusion_matches(gene1, gene2, gene_rules):
                out.write(line)
            # also try reversed (gene2::gene1)
            elif fusion_matches(gene2, gene1, gene_rules):
                out.write(line)

    infile.close()
    out.close()

###############################################################################
# 4. Main
###############################################################################
def Main():
    parser = argparse.ArgumentParser()

    parser.add_argument('--g', dest='genelist',
                        help='Custom fusion list with gene rules',
                        required=True)

    parser.add_argument('--f', dest='fusion',
                        help='Arriba discarded TSV',
                        required=True)

    args = parser.parse_args()

    rules = load_gene_list(args.genelist)
    filter_fusions(rules, args.fusion)


if __name__ == "__main__":
    Main()

### Run as python filter_fusions.py --g fusion_filter_list.txt --f NIQAS8gbg-RNA-V2.fusions.discarded.tsv