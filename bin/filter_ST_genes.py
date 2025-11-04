#!/usr/bin/env python

import json
import argparse

def load_fusion(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

def load_genes(gene_path):
    gene_list = []
    with open (gene_path, 'r') as file:
        for lines in file:
            line = lines.strip()
            gene_list.append(line)
    return(gene_list)

def filter_fusion(data, keys, genes):
    filtered_data = [item for item in data if any(item.get(key).split("_")[0] in genes for key in keys)]
    return filtered_data

def save_json(data, file_path):
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

def Main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-i",
        "--input",
        dest="input_file",
        default="agg.vcf",
        help="json of aggregated fusion",
    )
    parser.add_argument(
        "-g",
        "--genes",
        dest="selected_genes",
        default="ST",
        help="Genes in ST-RNA panels",
    )
    parser.add_argument(
        "-o",
        "--out",
        dest="output_file",
        default="filtered.vcf",
        help="Filtered Json aggregated fusion events",
    )
    
    args = parser.parse_args()
    input_Json = args.input_file
    output_Json = args.output_file
    gene_panel = args.selected_genes

    data = load_fusion(input_Json)
    genes_all = load_genes(gene_panel)
    filter_key = ['gene1', 'gene2']
    filtered_data = filter_fusion(data, filter_key, genes_all)
    save_json(filtered_data, output_Json)

if __name__ == "__main__":
    Main()
