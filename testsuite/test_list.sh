#!/bin/bash
# script for generating a list of exp files in particular directories
# expected output format is 
# scheduler.list = disjoint scheduler rulesort

echo "# automatically generated file -- DO NOT EDIT " 

# Process top-level directories
for name in bsc.*; do
    if [ -d "$name" ]; then
        dir=$(echo "$name" | cut -c5-)
        files=$(find "$name" -name "*.exp" -type f | sed 's/\.exp$//' | tr '\n' ' ')
        echo "$dir.list = $files"
    fi
done

# Add list definitions for 2nd level subdirectories
# targets are not bsc.interra/rtl_quality.group
for name in bsc.*/*/; do
    if [ -d "$name" ]; then
        dir=$(echo "$name" | cut -d/ -f1-2)
        files=$(find "$name" -name "*.exp" -type f | sed 's/\.exp$//' | tr '\n' ' ')
        echo "$dir.list = $files"
    fi
done

# Get all exp files
allexpfiles=$(find bsc.* -name "*.exp" -type f | sed 's/\.exp$//' | tr '\n' ' ')
echo "ALL.list = $allexpfiles"

# Process long tests
long=("$@")
echo "LONG.list = ${long[*]}"

# Generate dev list
devlist=()
for aname in $allexpfiles; do
    outname=$aname
    for lname in "${long[@]}"; do
        if [ "$aname" = "$lname" ]; then
            outname=""
        fi
    done
    if [ -n "$outname" ]; then
        devlist+=("$outname")
    fi
done

echo "dev.list = ${devlist[*]}"
