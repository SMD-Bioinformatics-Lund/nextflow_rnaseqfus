import argparse
import pysam

# Argument parsing
def parse_args():
    parser = argparse.ArgumentParser(description="Process BAM file and genome version.")
    parser.add_argument("-bam", required=True, help="Input BAM file.")
    parser.add_argument("-genome", required=True, choices=["hg19", "hg38", "grch38"],
                        help="Genome version: hg19, hg38, or grch38.")
    return parser.parse_args()

# Define IGH and D4Z4 regions
def define_regions(genome):
    IGHregion = {}
    D4Z4regions = []

    if genome == "hg19":
        IGHregion = {"chr": "chr14", "start": 106032614, "end": 107288051}
        D4Z4regions = [
            {"chr": "chr4", "start": 190988100, "end": 191007000},
            {"chr": "chr10", "start": 135477000, "end": 135500000},
            {"chr": "chrUn_gl000228", "start": 70000, "end": 115000},
        ]
    elif genome in ["hg38", "grch38"]:
        IGHregion = {"chr": "chr14", "start": 105700000, "end": 106900000}
        D4Z4regions = [
            {"chr": "chr4", "start": 190018000, "end": 190190000},
            {"chr": "chr10", "start": 133640000, "end": 133770000},
        ]

    return IGHregion, D4Z4regions

# Fetch alignments from BAM file
def fetch_alignments(bam_file, IGHregion):
    samfile = pysam.AlignmentFile(bam_file, "rb")
    alignments = samfile.fetch(IGHregion["chr"], IGHregion["start"], IGHregion["end"])
    return alignments

# Check if mate is in a D4Z4 region
def mate_in_region(mate_chr, mate_start, D4Z4regions):
    for region in D4Z4regions:
        if mate_chr == region["chr"] and region["start"] < mate_start < region["end"]:
            return True
    return False

# Process alignments
def process_alignments(alignments, D4Z4regions):
    matched_alignments = []

    for alignment in alignments:
        if alignment.is_unmapped or alignment.mate_is_unmapped:
            continue

        mate_chr = alignment.next_reference_name
        mate_start = alignment.next_reference_start

        if mate_in_region(mate_chr, mate_start, D4Z4regions):
            matched_alignments.append(alignment)

    return matched_alignments

# Count breakpoint-supporting reads
def count_breakpoints(matched_alignments, D4Z4regions):
    left_breaks = {}
    right_breaks = {}
    
    for alignment in matched_alignments:
        if alignment.is_reverse:
            strand = "-"
        else:
            strand = "+"

        cigar = alignment.cigarstring
        SA_tag = alignment.get_tag("SA") if alignment.has_tag("SA") else ""

        if strand == "+" and cigar.endswith("S") and SA_tag:
            SA_fields = SA_tag.split(",")
            SA_chr = SA_fields[0]
            SA_start = int(SA_fields[1])

            if mate_in_region(SA_chr, SA_start, D4Z4regions):
                end_pos = alignment.reference_end
                left_breaks[end_pos] = left_breaks.get(end_pos, 0) + 1

        elif strand == "-" and cigar.startswith("S") and SA_tag:
            SA_fields = SA_tag.split(",")
            SA_chr = SA_fields[0]
            SA_start = int(SA_fields[1])

            if mate_in_region(SA_chr, SA_start, D4Z4regions):
                start_pos = alignment.reference_start
                right_breaks[start_pos] = right_breaks.get(start_pos, 0) + 1

    return left_breaks, right_breaks

# Main function
def main():
    args = parse_args()

    bam_file = args.bam
    genome = args.genome

    IGHregion, D4Z4regions = define_regions(genome)
    alignments = fetch_alignments(bam_file, IGHregion)
    matched_alignments = process_alignments(alignments, D4Z4regions)

    left_breaks, right_breaks = count_breakpoints(matched_alignments, D4Z4regions)

    if left_breaks or right_breaks:
        print("Position\tDirection\tBreakpoint\tSupporting Reads")

        for pos, count in left_breaks.items():
            print(f"{IGHregion['chr']}:{pos}\t5'->3'\t5' of DUX4\t{count}")

        for pos, count in right_breaks.items():
            print(f"{IGHregion['chr']}:{pos}\t3'->5'\t3' of DUX4\t{count}")
    else:
        print("No breakpoint-supporting reads identified in IGH region")

if __name__ == "__main__":
    main()
