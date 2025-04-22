#!/bin/bash

# Function to calculate the correct number of parent directories
get_parent_dirs() {
    local path=$1
    local count=$(echo "$path" | tr -cd '/' | wc -c)
    local result=""
    for ((i=0; i<count; i++)); do
        result="../$result"
    done
    echo "$result"
}

# Find all Makefiles in the testsuite directory
find testsuite -name Makefile | while read -r makefile; do
    # Get the relative path from the Makefile to the root
    relative_path=$(dirname "$makefile")
    parent_dirs=$(get_parent_dirs "$relative_path")
    
    # Replace the CONFDIR line with the correct path
    sed -i.bak "s|CONFDIR = \$(realpath .*)|CONFDIR = \$(realpath $parent_dirs)|" "$makefile"
    rm -f "${makefile}.bak"
done 