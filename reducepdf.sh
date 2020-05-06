#!/bin/bash

# THIS SCRIPT REDUCES A SIZE OF PDF-FILE

# OPTIONS:
# -r to set resolution of page images
#    default resolution is 72

# Constants 
SCRIPT_NAME="$0"
CURDIR="$PWD"
DEFAULT_RESOLUTION=72 #DPI
DEFAUILT_MAX_SIZE=3000000

# Functions
check_file_type(){
    file_type="UNKOWN"
    file="$1"
    if test -f "$file"
    then
    file_type="file"
    fi
    
    if test -d "$file"
    then
    file_type="directory"
    fi
    echo $file_type
}

help(){
    echo USAGE:
    echo "$SCRIPT_NAME <file or directory> [options]"
    echo "Options:"
    echo "-r - resolution of output pages in dpi"
}

reduce_single_file(){
    file_to_reduce="$1"
    reduced_file1="$(basename -s '.pdf' "$file_to_reduce")""_reduced1.pdf"
    reduced_file2="$(basename -s '.pdf' "$file_to_reduce")""_reduced2.pdf"
    pdftocairo "$file_to_reduce" -jpeg -gray -r $resolution temp
    #pdftocairo "$file_to_reduce" -jpeg -gray -scale-to "$scale" temp
    img2pdf temp*.jpg -o "$reduced_file1"
    echo file "$reduced_file1" produced
    convert temp*jpg -page A4 "$reduced_file2"
    echo file "$reduced_file2" produced
    
    rm temp*.jpg
}

reduce_in_directory(){
    local dir="$1"
    local max_size=$2
    for file in "$dir"*.pdf
    do
        
        file_size=$(stat -c%s "$file")
        if [ "$file_size" -gt "$max_size" ]
        then
            echo "$file" size is greater than "$max_size"
            echo "... proceeding"
            reduce_single_file "$file"
        fi
        
    done
}

# First parameter must be file or directory, either -h for help
in_file="$1"
if [ "$in_file" = "-h" ] || [ "$in_file" = "-help" ]
then
    help
exit 1
fi

file_type=$(check_file_type "$in_file")
if [ "$file_type" = "UNKOWN" ]
then
    echo "First parameter must be file or directory." 
    echo \""$in_file"\"" does not exist"
    echo "------------------------------------------"
    help
exit 0
fi

# Obtaining user parameters (options)
resolution=$DEFAULT_RESOLUTION
max_size=$DEFAUILT_MAX_SIZE

#looping over parameters passed to the script
while [ -n "$1" ]; do
  case $1 in
    -r)
    shift
    resolution="$1"
    echo "resolution set to $resolution";;
    -s)
    shift
    max_size="$1"
    echo "only files exceeding $max_size bytes will be processed";;
  esac
  shift
done

scale=$(awk "BEGIN {print int((11+11/16)*$resolution)}")

# main activity
if [ "$file_type" = "file" ]
then
reduce_single_file "$in_file"
echo DONE
fi

if [ "$file_type" = "directory" ]
then
reduce_in_directory "$in_file" $max_size
echo DONE
fi

exit 1
