#!/usr/bin/env bash

# TODO could do $0 rather than basename?

#pwd
# pwd is C:\b\execroot\rules_foreign_cc_examples\bazel-out\x64_windows-fastbuild\bin\external\rules_foreign_cc\toolchains\pkg-config.exe.runfiles\rules_foreign_cc_examples
# echo "args are $@"

EXE=BIN
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
RUNFILES_DIR=${SCRIPT_DIR}/$(basename ${EXE}).runfiles
cd ${RUNFILES_DIR}

# if [[ ! -z "${EXT_BUILD_ROOT}" ]]; then
# cd "${EXT_BUILD_ROOT}"
# fi

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
    SHARED_LIB_SUFFIX=".so*"
    LIB_PATH_VAR=LD_LIBRARY_PATH
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SHARED_LIB_SUFFIX=".dylib"
    LIB_PATH_VAR=DYLD_LIBRARY_PATH
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    SHARED_LIB_SUFFIX=".dll"
    LIB_PATH_VAR=PATH
fi

# Add paths to shared libraries to SHARED_LIBS_ARRAY
SHARED_LIBS_ARRAY=()
while IFS=  read -r -d $'\0'; do
    SHARED_LIBS_ARRAY+=("$REPLY")
    # echo "The reply is $REPLY"
done < <(find . -name "*${SHARED_LIB_SUFFIX}" -print0)

# Add paths to shared library directories to SHARED_LIBS_DIRS_ARRAY
SHARED_LIBS_DIRS_ARRAY=()
for lib in "${SHARED_LIBS_ARRAY[@]}"; do
    SHARED_LIBS_DIRS_ARRAY+=($(dirname $(realpath $lib)))
done

# Remove duplicates from array
IFS=" " read -r -a SHARED_LIBS_DIRS_ARRAY <<< "$(tr ' ' '\n' <<< "${SHARED_LIBS_DIRS_ARRAY[@]}" | sort -u | tr '\n' ' ')"

# Allow unbound variable here, in case LD_LIBRARY_PATH or similar is not already set
set +u
# echo "SHARED_LIB_SUFFIX is ${SHARED_LIB_SUFFIX}"
for dir in "${SHARED_LIBS_DIRS_ARRAY[@]}"; do
    # echo "dir is ${RUNFILES_DIR}"
    export ${LIB_PATH_VAR}="$dir":"${!LIB_PATH_VAR}"
done
set -u



#script dir is /c/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/rules_foreign_cc/toolchains
# echo "script dir is ${SCRIPT_DIR}"
# ls ${SCRIPT_DIR}

#echo "exe is ${EXE}"
# echo "runfiles dir is ${RUNFILESDIR}"

#echo "runfiles dir is ${RUNFILES_DIR}"
#echo "rlocation is $(rlocation ${EXE#external/})"
# echo "about to find"
EXE_PATH=$(rlocation "${EXE#external/}")
#ls ${SCRIPT_DIR}/pkg-config.exe.runfiles
#/usr/bin/realpath .


# find .
#cmd /c echo %CD%
# The current working directory seems to be C:\b\execroot\rules_foreign_cc_examples\bazel-out\x64_windows-fastbuild\bin\external\rules_foreign_cc\toolchains\pkg-config.exe.runfiles\rules_foreign_cc_examples

# set +u
# if [[ ! -z "${EXT_BUILD_ROOT}" ]]; then
# cd -
# fi
# set -u

cd - &> /dev/null
# echo "pkgconfig path is ${PKG_CONFIG_PATH}"
# export PKG_CONFIG_PATH=C:/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/glib/glib.ext_build_deps/pcre/lib/pkgconfig

#export PKG_CONFIG_PATH=C:/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/glib/glib.ext_build_deps/libffi/lib/pkgconfig:C:/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/glib/glib.ext_build_deps/pcre/lib/pkgconfig:C:/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/glib/glib.ext_build_deps/zlib/share/pkgconfig

# export PKG_CONFIG_PATH=/c/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/glib/glib.ext_build_deps/pcre/lib/pkgconfig:/c/b/execroot/rules_foreign_cc_examples/bazel-out/x64_windows-fastbuild/bin/external/glib/glib.ext_build_deps/zlib/share/pkgconfig
exec ${EXE_PATH} "$@"



# TODO check that runfiles tree for pkg-config is created when running meson