#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
from collections import defaultdict
from typing import Dict, List, Any


# ---------------------------
# Utilities
# ---------------------------

def noversion(gene: str) -> str:
    return re.sub(r"\.\d+$", "", gene or "")


def read_blacklist(fn: str) -> Dict[str, int]:
    bl = {}
    with open(fn) as f:
        for line in f:
            bl[line.strip()] = 1
    return bl


def lines_file(fn: str) -> int:
    return int(subprocess.check_output(["wc", "-l", fn]).split()[0])


# ---------------------------
# TSV reader (simple replacement)
# ---------------------------
def read_tsv(fn: str):
    import csv
    with open(fn) as f:
        return list(csv.DictReader(f, delimiter="\t"))


# ---------------------------
# Fusion readers
# ---------------------------

def add_fusion(agg, genes, fusion_info):
    agg[genes].append(fusion_info)


def read_fusioncatcher(fn, agg):
    for fus in read_tsv(fn):
        gene1 = fus.get('Gene_1_symbol(5end_fusion_partner)')
        gene2 = fus.get('Gene_2_symbol(3end_fusion_partner)')
        genes = f"{noversion(gene1)}^{noversion(gene2)}"

        fusion_info = {
            "breakpoint1": fus.get('Fusion_point_for_gene_1(5end_fusion_partner)'),
            "breakpoint2": fus.get('Fusion_point_for_gene_2(3end_fusion_partner)'),
            "spanreads": int(fus.get("Spanning_unique_reads", 0) or 0),
            "spanpairs": int(fus.get("Spanning_pairs", 0) or 0),
            "longestanchor": fus.get("Longest_anchor_found"),
            "commonreads": int(fus.get("Counts_of_common_mapping_reads", 0) or 0),
            "desc": fus.get("Fusion_description"),
            "effect": fus.get("Predicted_effect"),
            "caller": "fusioncatcher",
        }

        if not re.search("banned", fusion_info["desc"] or ""):
            agg[genes].append(fusion_info)


def read_arriba(fn, agg):
    for fus in read_tsv(fn):
        gene1 = fus.get("#gene1")
        gene2 = fus.get("gene2")
        genes = f"{noversion(gene1)}^{noversion(gene2)}"

        r1 = int(fus.get("split_reads1", 0) or 0)
        r2 = int(fus.get("split_reads2", 0) or 0)

        fusion_info = {
            "breakpoint1": fus.get("breakpoint1"),
            "breakpoint2": fus.get("breakpoint2"),
            "spanreads": r1 + r2,
            "spanpairs": 0,
            "longestanchor": ">25" if (r1 + r2) > 25 else "<25",
            "desc": fus.get("confidence"),
            "effect": fus.get("reading_frame"),
            "caller": "arriba",
        }

        if not re.search("banned", fusion_info["desc"] or ""):
            agg[genes].append(fusion_info)


def read_starfusion(fn, agg):
    for fus in read_tsv(fn):
        gene1 = fus.get("LeftGene", "").split("^")[0]
        gene2 = fus.get("RightGene", "").split("^")[0]
        genes = f"{noversion(gene1)}^{noversion(gene2)}"

        fusion_info = {
            "breakpoint1": fus.get("LeftBreakpoint", "").replace("chr", ""),
            "breakpoint2": fus.get("RightBreakpoint", "").replace("chr", ""),
            "spanreads": fus.get("JunctionReadCount"),
            "spanpairs": fus.get("SpanningFragCount"),
            "FFPM": fus.get("FFPM"),
            "longestanchor": ">25" if fus.get("LargeAnchorSupport") == "YES_LDAS" else "<25",
            "caller": "starfusion",
        }

        agg[genes].append(fusion_info)


def read_fuseq(fn, agg):
    for fus in read_tsv(fn):
        genes = f"{noversion(fus.get('symbol5'))}^{noversion(fus.get('symbol3'))}"

        fusion_info = {
            "breakpoint1": f"{fus.get('chrom5')}:{fus.get('brpos5')}:{fus.get('strand5')}",
            "breakpoint2": f"{fus.get('chrom3')}:{fus.get('brpos3')}:{fus.get('strand3')}",
            "spanreads": fus.get("MR.passed"),
            "spanpairs": fus.get("SR.passed"),
            "desc": fus.get("info", ""),
            "caller": "fuseq",
        }

        agg[genes].append(fusion_info)


def read_jaffa(fn, agg):
    tmp = fn + ".tsv.tmp"

    subprocess.call(f"sed 's/,/\\t/g' {fn} > {tmp}", shell=True)
    subprocess.call(f"sed -i 's/\"//g' {tmp}", shell=True)

    for fus in read_tsv(tmp):
        genes_list = fus.get("fusion genes", "").split(":")
        if len(genes_list) < 2:
            continue

        gene1, gene2 = genes_list[:2]
        genes = f"{noversion(gene1)}^{noversion(gene2)}"

        fusion_info = {
            "breakpoint1": f"{fus.get('chrom1')}:{fus.get('base1')}:{fus.get('strand1')}",
            "breakpoint2": f"{fus.get('chrom2')}:{fus.get('base2')}:{fus.get('strand2')}",
            "spanreads": fus.get("spanning reads"),
            "spanpairs": fus.get("spanning pairs"),
            "effect": "in-frame" if fus.get("inframe") == "TRUE" else None,
            "desc": "mitelman" if fus.get("known") == "Yes" else None,
            "caller": "jaffa",
        }

        if fus.get("classification") == "HighConfidence" or "MECOM" in genes:
            agg[genes].append(fusion_info)


def read_exonskip(fn, agg):
    for fus in read_tsv(fn):
        genes = f"{noversion(fus.get('start_exon'))}^{noversion(fus.get('end_exon'))}"

        fusion_info = {
            "breakpoint1": fus.get("left_break", "").replace("chr", ""),
            "breakpoint2": fus.get("right_break", "").replace("chr", ""),
            "spanreads": fus.get("supporting_reads"),
            "spanpairs": 0,
            "effect": fus.get("effect"),
            "desc": fus.get("confidence"),
            "caller": "exonskip",
        }

        if not re.search("banned", fusion_info["desc"] or ""):
            agg[genes].append(fusion_info)


# ---------------------------
# Main
# ---------------------------

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fusioncatcher")
    parser.add_argument("--starfusion")
    parser.add_argument("--arriba")
    parser.add_argument("--fuseq")
    parser.add_argument("--jaffa")
    parser.add_argument("--exonskip")
    parser.add_argument("--priority", required=True)

    args = parser.parse_args()

    caller_priority = args.priority.split(",")

    blacklist = read_blacklist("/data/bnf/ref/fusion_blacklist")

    agg = defaultdict(list)

    if args.fusioncatcher:
        read_fusioncatcher(args.fusioncatcher, agg)
    if args.starfusion:
        read_starfusion(args.starfusion, agg)
    if args.arriba:
        read_arriba(args.arriba, agg)
    if args.fuseq:
        read_fuseq(args.fuseq, agg)
    if args.jaffa:
        read_jaffa(args.jaffa, agg)
    if args.exonskip and lines_file(args.exonskip) > 1:
        read_exonskip(args.exonskip, agg)

    # Select best per caller
    for genes, fus_list in agg.items():
        best = {}

        for f in fus_list:
            score = int(f.get("spanreads") or 0) + int(f.get("spanpairs") or 0)
            caller = f.get("caller")

            if caller not in best:
                best[caller] = f
            else:
                prev = best[caller]
                prev_score = int(prev.get("spanreads") or 0) + int(prev.get("spanpairs") or 0)

                if score > prev_score:
                    best[caller] = f

        for caller in caller_priority:
            if caller in best:
                best[caller]["selected"] = 1
                break

    output = []
    for genes, calls in agg.items():
        g1, g2 = genes.split("^")

        output.append({
            "genes": genes,
            "gene1": g1,
            "gene2": g2,
            "calls": calls,
            "blacklisted": 1 if genes in blacklist else 0
        })

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()