#!/bin/bash

RUNFILES_LIB_DEBUG=1

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2. (@bazel_tools//tools/bash/runfiles)
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
source "$0.runfiles/$f" 2>/dev/null || \
source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
{ echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

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
    SHARED_LIBS_DIRS_ARRAY[$(dirname $(realpath $lib))]=1
done

for dir in "${!SHARED_LIBS_DIRS_ARRAY[@]}"; do
    export ${LIB_PATH_VAR}="${!LIB_PATH_VAR}":"$dir"
done

echo "location is"
EXE=BIN
$(rlocation "${EXE#external/}")

# BIN $@
#ls

#cat ../MANIFEST


# have to --enable_runfiles

# How to get dependency DLLs here? The make_variant rule needs to have them as outputs? or runfiles?
#TODO perhaps make a helper macro in rules_foreign_cc for running binaries produced by rules_foreign_cc, which creates a sh_binary