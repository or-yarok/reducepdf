# Functions for number valiadation

validate_is_integer(){
  local value=$1
  if [[ $value ]] && [ $value -eq $value 2>/dev/null ]
  then
    return 0 # True
  else
    return 1 # False
  fi
}

# is a value positive integer?
validate_is_pos_int(){
    local value=$1
    if ! [[ ${value//[0-9]/""} ]]
    then
        return 0 # True; $1 has digits only
    else
        return 1 # False; $1 contains other letters besides digits
    fi
}
