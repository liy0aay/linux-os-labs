#!/bin/bash
set -euo pipefail

# analyzes process scheduling data from /proc to calculate Average Running Time (ART)

OUT_FILE="${1:-cpu_burst_with_avg.txt}"
> "$OUT_FILE"

declare -A ART_per_ppid  
declare -A count_per_ppid 
declare -a processes

# extract metrics directly from kernel structures in procfs
for pid_dir in /proc/[0-9]*; do
    [[ ! -r "$pid_dir/sched" || ! -r "$pid_dir/status" ]] && continue

    pid_num=$(basename "$pid_dir")
    ppid=$(awk '/^PPid:/ {print $2}' "$pid_dir/status")
    sum_exec_runtime=$(awk '/sum_exec_runtime/ {print $3}' "$pid_dir/sched")
    nr_switches=$(awk '/nr_switches/ {print $3}' "$pid_dir/sched")
    
    [[ -z "$nr_switches" || "$nr_switches" == "0" ]] && continue

    ART=$(awk -v sum="$sum_exec_runtime" -v nr="$nr_switches" 'BEGIN{printf "%.6f", sum/nr}')

    processes+=("$ppid:$pid_num:$ART")

    ART_per_ppid[$ppid]=$(awk -v a="${ART_per_ppid[$ppid]:-0}" -v b="$ART" 'BEGIN{print a+b}')
    count_per_ppid[$ppid]=$(( ${count_per_ppid[$ppid]:-0} + 1 ))
done

# sort processes by PPID 
IFS=$'\n' sorted=($(sort -t: -k1n <<<"${processes[*]}"))
unset IFS

current_ppid=""
for line in "${sorted[@]}"; do
    IFS=':' read -r ppid pid art <<< "$line"
    unset IFS

    if [[ "$current_ppid" != "" && "$current_ppid" != "$ppid" ]]; then
        avg=$(awk -v sum="${ART_per_ppid[$current_ppid]}" -v cnt="${count_per_ppid[$current_ppid]}" 'BEGIN{printf "%.6f", sum/cnt}')
        echo "Average_Running_Children_of_ParentID=$current_ppid is $avg" >> "$OUT_FILE"
    fi

    echo "ProcessID=$pid : Parent_ProcessID=$ppid : Average_Running_Time=$art" >> "$OUT_FILE"
    current_ppid=$ppid
done

# output the last grouped average
if [[ "$current_ppid" != "" ]]; then
    avg=$(awk -v sum="${ART_per_ppid[$current_ppid]}" -v cnt="${count_per_ppid[$current_ppid]}" 'BEGIN{printf "%.6f", sum/cnt}')
    echo "Average_Running_Children_of_ParentID=$current_ppid is $avg" >> "$OUT_FILE"
fi