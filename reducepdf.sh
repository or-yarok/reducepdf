#!/bin/bash
# REDUCE PDF-file SIZE
# (see DESCRIPTION variable or run the script with -h option)

# Constants
SCRIPT_NAME="$0"
CURDIR=$(dirname "$0") #where the script is located
DEFAULT_RESOLUTION=72 #DPI
DEFAUILT_MAX_SIZE=3000000 # bytes
DEFAULT_QUALITY=85 # percents
DEFUALT_METHOD=3 # 1 - img2pdf; 2 - convert (ImageMagick) utility; 3 - gs (gohstscript)
declare -A METHOD_NAMES
METHOD_NAMES[1]="img2pdf"
METHOD_NAMES[2]="convert (ImageMagick)"
METHOD_NAMES[3]="gs (ghostscript)"
declare -A DEPENDENCIES
DEPENDENCIES[1]="pdftocairo"
DEPENDENCIES[2]="img2pdf"
DEPENDENCIES[3]="convert"
DEPENDENCIES[4]="gs"
declare -A METHOD_REQUIREMENTS
METHOD_REQUIREMENTS[1]="12" # index of DEPENDENCIES required (pdftocairo and img2pdf)
METHOD_REQUIREMENTS[2]="13" # index of DEPENDENCIES required (pdftocairo and convert)
METHOD_REQUIREMENTS[3]="4"  # index of DEPENDENCIES required (gs)

PAGE_SIZE="A4"

DESCRIPTION="THIS SCRIPT REDUCES A SIZE OF PDF-FILE

USAGE:

 $SCRIPT_NAME <file or directory> [options]

DEPENDENCIES:
=============
The script will work properly if you have the necessary packages installed.
Description of the option \"-m\" bellow contains information which packages
are required for different methods of this script.

OPTIONS and the default values:
===============================
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
    1 for the ${METHOD_NAMES[1]} utility, required: ${DEPENDENCIES[1]} and ${DEPENDENCIES[2]} ;
    2 for the ${METHOD_NAMES[2]} utility, required: ${DEPENDENCIES[1]} and ${DEPENDENCIES[3]} ;
    3 for the ${METHOD_NAMES[3]} utility, required: ${DEPENDENCIES[4]}.
    The default method is $DEFUALT_METHOD (${METHOD_NAMES[$DEFUALT_METHOD]}).
"

# Functions

. "${CURDIR}""/numvalidation.sh"

calc(){
    calculations=$1
    bc <<< "scale=2; $calculations"
}

isPackageInstalled(){
    local pkg
    pkg="$(which "$1")"
    if [ -z "$pkg" ]; then
        return 1 # not installed
    else
        return 0 # installed
    fi
}

check_requirements(){
	local pkg=""
	method_num=$1
	# method_name=${METHOD_NAMES[$method_num]}
	requirements=${METHOD_REQUIREMENTS[$method_num]}
	all_dependencies_solved=0
	while [[ -n $requirements ]]; do
		pkg=${DEPENDENCIES[$(echo $requirements | head -c 1)]}
		requirements=${requirements:1} #equivalent to $(echo $requirements | sed -e "s/^.//")
		isPackageInstalled $pkg
		pkg_is_installed=$? # result of testing whether $pkg isinstalled (0), or not (1)
		all_dependencies_solved=$((all_dependencies_solved+pkg_is_installed))
	done
	return $all_dependencies_solved
}

nicesize(){
bytes=$1
nicesize=$1" bytes"
if [[ bytes -gt 1048576 ]]; then
    nicesize=$(calc "$bytes""/1048576")" MiB"
elif [[ bytes -gt 1024 ]]; then
    nicesize=$(calc "$bytes""/1024")" KiB"
fi

echo "$nicesize"
return 0

}

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

validate_resolution(){
  local value=$1
  min_resolution=30
  max_resolution=300
  validate_is_pos_int "$value"
  is_value_pos_int=$?
  if [[ "$is_value_pos_int" -eq 0 ]] && [ "$value" -le $max_resolution ] && [ "$value" -ge $min_resolution ]
  then
    return 0 # True (valid)
  else
    return 1 # False (not valid)
  fi
}

validate_quality(){
    local value=$1
    min_quality=1
    max_quality=100
    validate_is_pos_int "$value"
    is_value_pos_int=$?
    if [[ "$is_value_pos_int" -eq 0 ]] && [ "$value" -le $max_quality ] && [ "$value" -ge $min_quality ]
    then
        return 0 # True (valid)
    else
        return 1 # False (not valid)
    fi
}

validate_method(){
	local value=$1
	if [[ $value = "1" ]] || [[ $value = "2" ]] || [[ $value = "3" ]]
	then
		check_requirements "$value"
		is_requirements_met=$?
		if [[ "$is_requirements_met" = "0" ]]; then
			return 0 # all necessary packages for method ${METHOD_NAMES[$value]} exist
		else
			return "$is_requirements_met" # number of absent packages
		fi
    else
        return 10 # not valid method number
    fi

}

help(){
    echo "$DESCRIPTION"
}


get_random_letters(){
    length=$1
    letters_range='a-zA-Z'
    sequence=$( cat /dev/urandom | tr -dc $letters_range | fold -w $length | head -n 1  )
    echo "$sequence"
    return 0
}

make_jpeg_from_pdf(){
    local source_pdf=$1
    local jpeg_names_template=$2
    pdftocairo -jpeg -gray -r $resolution -jpegopt "quality=$quality" "$source_pdf" "$jpeg_names_template"
}

reduce_single_file(){
    file_to_reduce="$1"
    reduced_file="$(basename -s '.pdf' "$file_to_reduce")""_reduced.pdf"
    # random names for temporary files are generating in order to avoid coninciting with existing files
    temporary_files_template=$(get_random_letters 8)
    #pdftocairo "$file_to_reduce" -jpeg -gray -r $resolution -jpegopt "quality=$quality" $temporary_files_template
    #pdftocairo "$file_to_reduce" -jpeg -gray -scale-to "$scale" temp
    case $method in

        1) make_jpeg_from_pdf "$file_to_reduce" "$temporary_files_template"
        img2pdf "$temporary_files_template"*.jpg -S "$PAGE_SIZE" -o "$reduced_file"
        rm "$temporary_files_template"*.jpg;;

        2) make_jpeg_from_pdf "$file_to_reduce" "$temporary_files_template"
        convert "$temporary_files_template"*.jpg -page "$PAGE_SIZE" "$reduced_file"
        rm "$temporary_files_template"*.jpg;;

        3) settings="/ebook"
        if [[ $resolution -lt 96 ]]; then settings="/screen"; fi
        if [[ $resolution -gt 199 ]]; then settings="/printer"; fi
        ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
		-dPDFSETTINGS="$settings" -dNOPAUSE -dQUIET -dBATCH \
		-sOutputFile="$reduced_file" "$file_to_reduce"


    esac
	if [[ -e "$reduced_file" ]]; then
		reduced_size=$(stat -c%s "$reduced_file")
		init_size=$(stat -c%s "$file_to_reduce")
		reduce_ratio=$(awk "BEGIN {print ($reduced_size/$init_size)*100}")"%"
		nice_reduced_size=$(nicesize "$reduced_size")
		echo -e "file ""$reduced_file"" produced\n     of ""$nice_reduced_size"" bytes (""$reduce_ratio"" of the initial size)"
	else echo "something went wrong..."
	fi
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
    echo "First parameter must be file or directory, or -h for help."
    echo "file < $in_file >"" does not exist"
    echo "------------------------------------------"
    help
exit 0
fi

## Obtaining user parameters (options)
resolution=$DEFAULT_RESOLUTION
max_size=$DEFAUILT_MAX_SIZE
quality=$DEFAULT_QUALITY
method=""


#looping over parameters passed to the script
while [ -n "$1" ]; do
  case $1 in
    -r)
    shift
	validate_resolution "$1"
	is_resolution_valid=$?
    if [[ $is_resolution_valid = "0" ]]
    then
        resolution="$1"
        echo "resolution set to $resolution"
	else
		echo "the given resolution $1 is not valid; the default resolution $DEFAULT_RESOLUTION will be used"
    fi;;

    -s)
    shift
    max_size="$1"
    echo "only files exceeding $max_size bytes will be processed";;

    -q)
    shift
    validate_quality "$1"
    is_quality_valid=$?
    if [[ $is_quality_valid = "0" ]]
    then
        quality="$1"
        echo "pages will be compressed using quality value of $quality"
    else
        echo "the given quality $1 is not valid; the default quality $DEFAULT_QUALITY will be used."
    fi;;

    -m)
    shift
	validate_method "$1"
	is_method_valid=$?
    if [[ $is_method_valid = "0" ]]
    then
        method="$1"
        echo "Method number $method is given: ${METHOD_NAMES[$method]} will be used"
    elif [[ $is_method_valid = "10" ]]
    then
        echo "not valid method number, the default method will be used"
    else
        echo $is_method_valid " package(s) required for the choosen method are (is) not installed. I will try to use the default method"
    fi;;
  esac
  shift
done

if [ -z "$method" ]; then
	method=$DEFUALT_METHOD
	check_requirements $method
	is_requirements_met=$?
	if [[ "$is_requirements_met" != 0 ]]; then
		echo $is_requirements_met "packages are required and not installed"
		help
		exit 1
	fi
fi

# scale parameter will be implemented in the future:
# scale=$(awk "BEGIN {print int((11+11/16)*$resolution)}")

# main activity
if [ "$file_type" = "file" ]
then
    reduce_single_file "$in_file"
    echo DONE
fi

if [ "$file_type" = "directory" ]
then
    reduce_in_directory "$in_file" "$max_size"
    echo DONE
fi

exit 0
