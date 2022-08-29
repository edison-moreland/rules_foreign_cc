#!/bin/bash

BIN=$1
shift

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SHARED_LIB_SUFFIX=".so"
    LIB_PATH_VAR=LD_LIBRARY_PATH
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SHARED_LIB_SUFFIX=".dylib"
    LIB_PATH_VAR=PATH
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    SHARED_LIB_SUFFIX=".dll"
    LIB_PATH_VAR=PATH
fi

readarray -d '' SHARED_LIBS_ARRAY < <(find . -name "*${SHARED_LIB_SUFFIX}" -print0)

declare -A SHARED_LIBS_DIRS_ARRAY
for lib in "${SHARED_LIBS_ARRAY[@]}"; do
    SHARED_LIBS_DIRS_ARRAY[$lib]=1
done
echo ${!SHARED_LIBS_DIRS_ARRAY[@]}


# for lib in "${SHARED_LIBS_ARRAY[@]}"; do
# export ${LIB_PATH_VAR}=${!LIB_PATH_VAR}:$(dirname $(realpath $lib))
# done

# $BIN $@


# have to --enable_runfiles

# How to get dependency DLLs here? The make_variant rule needs to have them as outputs? or runfiles?
#TODO perhaps make a helper macro in rules_foreign_cc for running binaries produced by rules_foreign_cc, which creates a sh_binary