#!/bin/bash
# REDUCE PDF-file SIZE
# (see DESCRIPTION variable or run the script with -h option)

# Constants
SCRIPT_NAME="$0"
CURDIR="$PWD"
DEFAULT_RESOLUTION=72 #DPI
DEFAUILT_MAX_SIZE=3000000 # bytes
DEFAULT_QUALITY=85
DEFUALT_METHOD=1 # 1 - img2pdf; 2 - convert (ImageMagick) utility
declare -A METHOD_NAMES
METHOD_NAMES[1]="img2pdf"
METHOD_NAMES[2]="convert (ImageMagick)"

DESCRIPTION="THIS SCRIPT REDUCES A SIZE OF PDF-FILE

USAGE:
+--------------------------------------------+
| $SCRIPT_NAME <file or directory> [options] |
+--------------------------------------------+

DEPENDENCIES:
=============
The script will work properly if you have installed:
- pdftocairo
- ImageMagick and/or img2pdf

OPTIONS:
========
-r <resolution in dpi> to set resolution of page images.
    Default resolution is 72. Value in the interval 30..300
    are allowable
-s <file size in bytes> to set the maximum file size.
    The script will process all the files whose size exceeds
    the maximum size.
    The default value is 3000000 bytes (files of 3000000 bytes
    in size and less will not be processed by default).
-q <jpeg quality, %> takes values from 1 up to 100.
    Default value is 85.
-m <number of method>: to choose a utility to compose a pdf-
    file:
    1 for the ${METHOD_NAMES[1]} utility,
    2 for the ${METHOD_NAMES[2]} utility.
    The default method is 1 (img2pdf).
"


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

validate_is_integer(){
  local value=$1
  if [[ $value ]] && [ $value -eq $value 2>/dev/null ]
  then
    return 0 # True
  else
    return 1 # False
  fi
}

validate_resolution(){
  local value=$1
  min_resolution=30
  max_resolution=300
  validate_is_integer $value
  if [[ $? -eq 0 ]] && [ $value -le $max_resolution ] && [ $value -ge $min_resolution ]
  then
    return 0 # True (valid)
  else
    echo "Valid resolution is a number between $min_resolution and $max_resolution"
	echo "The default resolution $DEFAULT_RESOLUTION will be used."
    return 1 # False (not valid)
  fi
}

validate_quality(){
    local value=$1
    min_quality=1
    max_quality=100
    validate_is_integer $value
    if [[ $? -eq 0 ]] && [ $value -le $max_quality ] && [ $value -ge $min_quality ]
    then
        return 0 # True (valid)
    else
        echo "Valid quality of jpeg compression is a number between $min_quality and $max_quality"
        echo "The default value $DEFAULT_QUALITY will be used"
        return 1 # False (not valid)
    fi
}

validate_method(){
	local value=$1
	if [[ $value -eq 1 ]] || [[ $value -eq 2 ]]
	then
        return 0
    else
        echo "Not valid method number. The method $DEFUALT_METHOD will be used."
        return 1
    fi

}

help(){
    echo "$DESCRIPTION"
}

reduce_single_file(){
    file_to_reduce="$1"
    reduced_file="$(basename -s '.pdf' "$file_to_reduce")""_reduced.pdf"
    #reduced_file2="$(basename -s '.pdf' "$file_to_reduce")""_reduced2.pdf"
    pdftocairo "$file_to_reduce" -jpeg -gray -r $resolution -jpegopt "quality=$quality" temp
    #pdftocairo "$file_to_reduce" -jpeg -gray -scale-to "$scale" temp
    case $method in
        1) img2pdf temp*.jpg -o "$reduced_file";;
        2) convert temp*jpg -page A4 "$reduced_file";;
    esac
	if [[ -e "$reduced_file" ]]; then
		reduced_size=$(stat -c%s "$reduced_file")
		init_size=$(stat -c%s "$file_to_reduce")
		reduce_ratio=$(awk "BEGIN {print ($reduced_size/$init_size)*100}")"%"
		echo -e "file "$reduced_file" produced\n     of $reduced_size bytes ("$reduce_ratio" of the initial size)"
	else echo "something went wrong..."
	fi

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
quality=$DEFAULT_QUALITY
method=$DEFUALT_METHOD


#looping over parameters passed to the script
while [ -n "$1" ]; do
  case $1 in
    -r)
    shift
    validate_resolution "$1"
    if [ $? -eq 0 ]
    then
        resolution="$1"
        echo "resolution set to $resolution"
    fi;;
    -s)
    shift
    max_size="$1"
    echo "only files exceeding $max_size bytes will be processed";;
    -q)
    shift
    validate_quality "$1"
    if [ $? -eq 0 ]
    then
        quality="$1"
        echo "pages will be compressed using quality value of $quality"
    fi;;
	-m)
	shift
	validate_method "$1"
	if [ $? -eq 0 ]
	then
		method="$1"
		echo "Method number $method is given: ${METHOD_NAMES[$method]} will be used"
	fi;;
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

exit 0
