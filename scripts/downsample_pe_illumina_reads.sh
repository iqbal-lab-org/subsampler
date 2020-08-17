#!/usr/bin/env bash
if [[ "$#" -lt 7 ]]; then
    echo "Error: Illegal number of parameters"
    echo -e "usage:\n$(basename "$0") <reads_1> <reads_2> <ref> <covg> <outname_1> <outname_2> <seed>"
    exit 1
fi

set -euv

reads_1="$1"
reads_2="$2"
ref="$3"
covg="$4"
outname_1="$5"
outname_2="$6"
seed="$7"

genome_size=$(grep -v '^>' "$ref" | wc | awk '{print $3-$1}')
rasusa --input "$reads_1" "$reads_2" \
    --coverage "$covg" \
    --genome-size "$genome_size" \
    --output "$outname_1" "$outname_2" \
    --seed "$seed"
