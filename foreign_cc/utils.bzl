""" This file contains useful utilities """
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

def _full_label(label):
    return native.repository_name() + "//" + native.package_name() + ":" + label

def runnable_binary(name, binary, foreign_cc_target, **kwargs):
    """
    Macro that provides a wrapper script around a binary generated by a rules_foreign_cc rule that can be run using "bazel run".

    The wrapper script also facilitates the running of binaries that are dynamically linked to shared libraries also built by rules_foreign_cc. The runnable bin could be used as a tool in a dependent bazel target

    Note that this macro only works on foreign_cc_targets in external repositories, not in the main repository. This is due to the issue described here: https://github.com/bazelbuild/bazel/issues/10923
    Also note that the macro requires the `--enable_runfiles` option to be set on Windows.

    Args:
        name: The target name
        binary: The name of the binary generated by rules_foreign_cc
        foreign_cc_target: The target that generates the binary
        **kwargs: Remaining keyword arguments
    """

    tags = kwargs.pop("tags", [])

    native.filegroup(
        name = name + "_fg",
        srcs = [foreign_cc_target],
        tags = tags + ["manual"],
        output_group = binary,
    )

    native.genrule(
        name = name + "_wrapper",
        srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_binary_wrapper.sh", name + "_fg"],
        outs = [name + "_wrapper.sh"],
        cmd = "sed s@BIN@$(rootpath {})@g $(location @rules_foreign_cc//foreign_cc/private:runnable_binary_wrapper.sh) > $@".format(_full_label(name + "_fg")),
        tags = tags + ["manual"],
    )

    native.sh_binary(
        name = name + "_sh",
        deps = ["@bazel_tools//tools/bash/runfiles"],
        srcs = [name + "_wrapper"],
        data = [
            name + "_fg",
            foreign_cc_target,
        ],
        **kwargs
    )

    # sh_binary provides more than one output file, preventing the use of make variable expansion such as "location"; the plural "locations" must be used instead
    # Wrap the sh_binary in a skylib native_binary to faciliate single output and usage of singular make variable expansion, i.e. "location"
    native_binary(
        name = name,
        src = name + "_sh",
        out = name + ".exe",
        **kwargs
    )

    native.genrule(
        name = "blob",
        srcs=[name],
        outs=["blob.txt"],
        cmd="ls $(locations {})".format(name),
        executable=True
    )



#     native.genrule(
#         name = name,
#         srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_bin_wrapper.sh", name + "_fg", foreign_cc_target],
#         outs = ["runnable_{}".format(name)],
#         executable= True,
#         cmd = """
# if [[ "$$OSTYPE" == "linux-gnu"* ]]; then
#     SHARED_LIB_SUFFIX=".so"
#     LIB_PATH_VAR=LD_LIBRARY_PATH
# elif [[ "$$OSTYPE" == "darwin"* ]]; then
#     SHARED_LIB_SUFFIX=".dylib"
#     LIB_PATH_VAR=PATH
# elif [[ "$$OSTYPE" == "msys" || "$$OSTYPE" == "cygwin" ]]; then
#     SHARED_LIB_SUFFIX=".dll"
#     LIB_PATH_VAR=PATH
# fi

# readarray -d '' SHARED_LIBS_ARRAY < <(find . -name "*$$SHARED_LIB_SUFFIX" -print0)

# declare -A SHARED_LIBS_DIRS_ARRAY
# for lib in "$${{SHARED_LIBS_ARRAY[@]}}"; do
#     SHARED_LIBS_DIRS_ARRAY[$$(dirname $$(realpath $$lib))]=1
# done

# for dir in "$${{!SHARED_LIBS_DIRS_ARRAY[@]}}"; do
#     export $$LIB_PATH_VAR="$${{!LIB_PATH_VAR}}":"$$dir"
# done

#  $(location {}) $$@
#         """.format(name + "_fg"),
#         **kwargs
#     )

    # Seems that "bazel run" on windows will try to run the blob.sh output as is and fail to do so. Instead, create a sh_binary from blob.sh generated here
    native.genrule(
        name = "blob2",
        srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_bin_wrapper.sh", name + "_fg"],
        outs = ["blob.sh"],
        cmd = "sed s@BIN@$(rootpath {})@g $(location @rules_foreign_cc//foreign_cc/private:runnable_bin_wrapper.sh) > $@".format(full_label(name + "_fg")),
        executable=True,
        # cmd = "ls $(location {}) > $@".format(name + "_fg")
    )

    # But now the blob.sh has the path to the exe to run in the build tree rather than in the sh_bin
    native.sh_binary(
        name = "blob3",
        deps = ["@bazel_tools//tools/bash/runfiles"],
        srcs = ["blob2"],
        data = [
            name + "_fg",
            foreign_cc_target
        ],
        **kwargs
    )

    native.genrule(
        name = "blob3_2",
        tools = ["blob3"],
        outs = ["blob3_2.sh"],
        cmd = "$(location blob3)",
        executable=True,
        # cmd = "ls $(location {}) > $@".format(name + "_fg")
    )    

    native.sh_binary(
        name = "blob4",
        srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_bin_wrapper.sh"],
        deps = ["@bazel_tools//tools/bash/runfiles"],
        # data = [
        #     name + "_fg",
        #     foreign_cc_target
        # ],
        **kwargs
    )

    # native.genrule(
    #     name = "blob5",
    #     srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_bin_wrapper.sh", name + "_fg"],
    #     outs = ["blob5.sh"],
    #     cmd = "sed s%BIN%{}%g $(location @rules_foreign_cc//foreign_cc/private:runnable_bin_wrapper.sh) > $@".format(full_label(binary)),
    #     executable=True,
    #     # cmd = "ls $(location {}) > $@".format(name + "_fg")
    # )

    # native.sh_binary(
    #     name = "blob6",
    #     srcs = ["blob5"],
    #     deps = ["@bazel_tools//tools/bash/runfiles"],
    #     data = [
    #         name + "_fg",
    #         foreign_cc_target
    #     ],
    #     **kwargs
    # )

    # Instead do this approach - https://stackoverflow.com/questions/53472993/how-do-i-make-a-bazel-sh-binary-target-depend-on-other-binary-targets/53481508#53481508


#https://stackoverflow.com/questions/47068989/how-to-compute-the-bazel-workspace-name-in-a-macro
def full_label(label):
    if native.repository_name() != "@":
        print("full label is a ", native.repository_name() + '//' + native.package_name() + ':' + label)
        return native.repository_name() + '//' + native.package_name() + ':' + label
    else:
        print("full label is b ", native.repository_name() + '//' + native.package_name() + ':' + label)
        return native.repository_name() + '//' + native.package_name() + ':' + label


# binary is "select()", so cant use that
# Perhaps best to make a custom rule that is basically a reimplementation of genrule except it runs a binary and sets the correct environment variables to include the .so/dll/dylibs


# actually using "$(rootpath)" in blob2 


def test(label):
    print(Label(full_label(label)).workspace_root)
    return label


# Currently, "bazel run :blob3 --enable_runfiles" works, i just need to somehow get the workspace name programatically