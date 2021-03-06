#!/usr/bin/env bash

#####
# Private functions
#####
__proj_cd()
{
    local PROJ_DIR="$(__proj_get_dir_by_name "$1")"

    # bold "PROJ_DIR" "$PROJ_DIR"

    # Check if proj directory exists
    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Project directory of '$1' not found.")" \
        --fxit

    # cd to the directory
    test cd "$PROJ_DIR" \
        --fe "$(err "Cannot access to the project directory.")" \
        --fxit
}

# Check if given name is a valid name to be registered.
__proj_name_is_valid()
{
    # Valid name must begins with any word character (including digit) followed by any word character, dash, or underscore.
    echo "$1" | grep -oqP "^\w{1}[\w-_]*"
}

# Get proj directory path from ./MAP file by given proj name.
__proj_get_dir_by_name()
{
    # bold "1" "$1"
    cat "$PROJECT_MAP" | grep -oP "(?<=$1=).*"
}

# Check if proj exists (registered) by given name
__proj_exists_by_name()
{
    cat $PROJECT_MAP | grep -oqP "^$1(?==)"
}

# Check if proj exists (registered) by given path
__proj_exists_by_dir()
{
    cat $PROJECT_MAP | grep -oqP "^.+(?<==)$1$"
}

# Get a single line of ./MAP file
# It is a key-value pair for mapping proj name and its directory
__proj_map_get()
{
    local DIR="$(cat $PROJECT_MAP | grep -P "^$1=")"

    # bold "PROJECT_MAP" "$PROJECT_MAP"
    # bold "1" "$1"
    # bold "2" "$2"
    # bold "DIR" "$DIR"

    if [ "$DIR" != "" ]; then
        echo "$DIR"
        return 0
    fi

    DIR="$(cat $PROJECT_MAP | grep -P "=$2$")"

    # bold "1" "$1"
    # bold "2" "$2"
    # bold "DIR" "$DIR"

    if [ "$DIR" != "" ]; then
        echo "$DIR"
        return 0
    fi
    
    return 1
}

# Append key-value pair mapping data to ./MAP file
__proj_map_add()
{
    # bold "MAP" "${1}=${2}"
    # bold "PROJECT_MAP" "$PROJECT_MAP"
    # bold "DIR" "$DIR"

    echo "${1}=${2}" >> "$PROJECT_MAP"
}

# Override existing mapping data
__proj_map_override()
{
    # bold "MAP_GET" "$(__proj_map_get "$1" "$2")"
    local MAPPED="$(__proj_map_get "$1" "$2")"

    # bold "MAPPED" "$MAPPED"

    sed -i "s,$MAPPED,${1}=${2},g" $PROJECT_MAP
}

# Remove existing mapping data
__proj_map_remove()
{
    sed -i "\,$1,d" $PROJECT_MAP
}

__proj_escape_dir_path()
{
    echo "$1" | grep -qP "^\w+"

    if [ $? -eq 0 ]; then
        echo "$(echo "$1" | awk '{ print "./" $0 }')"
        return 0
    fi

    echo "$1"
    return 0
}