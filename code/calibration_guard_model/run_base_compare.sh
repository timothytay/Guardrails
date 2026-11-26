#!/bin/bash
# Compare a guard model's confidence with that of its base LMs.
# All three models get the guard's exact prompt and are scored the same way
# ("forced" scoring: read P(safe)/P(unsafe) at the guard's answer position).
#
# Usage:  bash run_base_compare.sh [dataset] [mode] [cal_method]
#   e.g.  bash run_base_compare.sh xs-test prompt origin
#         bash run_base_compare.sh harmbench-adv prompt-response cc

dataset=${1:-xs-test}
mode=${2:-prompt}
cal_method=${3:-origin}

guard='meta-llama/Llama-Guard-3-1B'
base_lms='meta-llama/Llama-3.2-1B meta-llama/Llama-3.2-1B-Instruct'
out_dir="results_guard/basecmp"
PY=${PY:-.venv/bin/python}

# The guard itself, scored with the same forced method as the base LMs
$PY -u eval.py --cls_path $guard --dataset $dataset --mode $mode \
    --cal_method $cal_method --scoring forced \
    --save_path "${out_dir}/${dataset}_${mode}_${cal_method}_$(basename $guard).json"

# Each base LM, using the guard's prompt format
for lm in $base_lms; do
    $PY -u eval.py --cls_path $guard --base_lm $lm --dataset $dataset --mode $mode \
        --cal_method $cal_method \
        --save_path "${out_dir}/${dataset}_${mode}_${cal_method}_$(basename $lm).json"
done
