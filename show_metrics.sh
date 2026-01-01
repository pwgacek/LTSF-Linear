#!/bin/bash

if [ -z "$1" ]; then
    echo "Use: $0 <results_directory>"
    exit 1
fi

results_dir="$1"

if [ ! -d "$results_dir" ]; then
    echo "Error: Directory $results_dir does not exist"
    exit 1
fi

# Find all .log files recursively and sort them
for file in $(find "$results_dir" -name "*.log" | sort); do
    if [ -f "$file" ]; then
        echo "=== $file ==="
        tail -n 1 "$file"
        echo
    fi
done
