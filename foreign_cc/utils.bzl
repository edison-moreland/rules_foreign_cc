""" This file contains useful utilities """
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")


def _full_label(label):
    return native.repository_name() + "//" + native.package_name() + ":" + label

# TODO  make final executable have the same name as “binary” arg, so that when added to path it is recognised by tools like meson and autotools 
def runnable_binary(name, binary, foreign_cc_target, match_binary_name=False, **kwargs):
    """
    Macro that provides a wrapper script around a binary generated by a rules_foreign_cc rule that can be run using "bazel run".

    The wrapper script also facilitates the running of binaries that are dynamically linked to shared libraries also built by rules_foreign_cc. The runnable bin could be used as a tool in a dependent bazel target

    Note that this macro only works on foreign_cc_targets in external repositories, not in the main repository. This is due to the issue described here: https://github.com/bazelbuild/bazel/issues/10923
    Also note that the macro requires the `--enable_runfiles` option to be set on Windows.

    Args:
        name: The target name
        binary: The name of the binary generated by rules_foreign_cc, should not include .exe extension
        foreign_cc_target: The target that generates the binary
        **kwargs: Remaining keyword arguments
    """

    tags = kwargs.pop("tags", [])

    native.filegroup(
        name = name + "_fg",
        srcs = [foreign_cc_target],
        tags = tags + ["manual"],
        output_group =  select({
        "@platforms//os:windows": binary + ".exe",
        "//conditions:default": binary,
        }),
        visibility = ["//visibility:public"],
    )

    native.genrule(
        name = name + "_wrapper",
        srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_binary_wrapper.sh", name + "_fg"],
        outs = [name + "_wrapper.sh"],
        cmd = "sed s@BIN@$(rootpath {})@g $(location @rules_foreign_cc//foreign_cc/private:runnable_binary_wrapper.sh) > $@".format(_full_label(name + "_fg")),
        tags = tags + ["manual"],
        visibility = ["//visibility:public"],
    )

    native.filegroup(
        name = "workaround_fg",
        srcs = [name + "_fg", foreign_cc_target, name + "_wrapper"],
        tags = tags + ["manual"],
        visibility = ["//visibility:public"],
    )
    native.sh_library(
        name = "workaround",
        data = [name + "_wrapper",name + "_fg", foreign_cc_target, ":workaround_fg"],
        visibility = ["//visibility:public"],
    )

    native.sh_binary(
        name = name + "_sh" if match_binary_name else name,
        deps = ["@bazel_tools//tools/bash/runfiles"],
        data = [name + "_fg"],
        srcs = [name + "_wrapper"],
        tags = tags + ["manual"],
        **kwargs
    )

    # TODO use skylib to copy file or create symlink to output of of sh_binary to be able to give it a certain name, eg pkg-config.exe autotools, cmake etc pick it up
    # or instead change name attribute of sh_binary to match "binary", although this conflicts eg in openssl BUILD file, the lib is called openssl and the runnable bin is called openssl
    # Although this may not be necessary if autotools, cmake, meson can be told path to pkg-config.
    # Or rules_foreign_cc could create the symlink.


    # native.genrule(
    #     name = name + "_genrule",
    #     srcs = [name + "_sh"],
    #     outs = [name + "out.sh"],
    #     cmd = "echo hi > $@",
    #     tags = tags + ["manual"],
    #     executable = True,
    #     visibility = ["//visibility:public"],
    # )

    # native.filegroup(
    #     name = name + "_sh_fg",
    #     srcs = [name + "_sh"],
    # )

    # native.genrule(
    #     name = name,
    #     srcs = [name + "_genrule"],
    #     outs = [name + "out2.sh"],
    #     cmd = "echo hi > $@",
    #     tags = tags + ["manual"],
    #     visibility = ["//visibility:public"],
    # )    

    # TODO instead of doing the below, instead just have sh_binary with "name" set to "binary" and have an alias so that the "name" target points to the sh_binary
    if match_binary_name:
        # sh_binary provides more than one output file, preventing the use of make variable expansion such as "location"; the plural "locations" must be used instead
        # # Wrap the sh_binary in a skylib native_binary to faciliate single output and usage of singular make variable expansion, i.e. "location"
        native_binary(
            name = name,
            # Why does the below work but not name + "_sh"?
            src = name + "_sh",
            #src = name + "_sh",
            # out = binary,
            out =  select({
            "@platforms//os:windows": binary + ".exe",
            "//conditions:default": binary,
            }),        
            data = [name + "_wrapper_copy"],
            tags = tags,
            **kwargs
        )

        # TODO instead try changing native_tool_toolchain to use ctx.resolve_command. See https://github.com/angular/dev-infra/commit/7605373472c9eb4aa0c35f6df2f02bb12db94e3c
        # If that fails, Try replacing sh_binary with custom starlark rule that does the same thing but outputs only one file. Or Try replacing sh_binary on windows for a genrule that produces a .bat script that calls bash.exe -c script.sh. See if BAZEL_SH can be used. Test when running in mingw and cmd promo 


        # # TODO make sure it works with windows_enable_symlinks startup option. also set msys winsymblinks action env
        # # This is necessary because it seems that on windows sh_binary creates an .exe that must have the script with same name without exe extension, otherwise it fails. As we are using native_binary above we need to copy
        # This is only required for windows
        # TODO - perhaps have arg to this macro to say if the file should have same name as the binary, in which case there must not be an existing target with same name. Have this arg default to false
        copy_file(
            name = name + "_wrapper_copy",
            src = name + "_wrapper",
            # TODO handle this better
            out = binary,
            tags = tags + ["manual"],
            **kwargs
        )

    # native.genrule(
    #     name = name + "_bat",
    #     srcs = [name + "_sh"],
    #     outs = [name + ".bat"],
    #     executable = True,
    #     # cmd_bat = "cmd /c $(locations :{}_sh)".format(name)
    #     # cmd_bat = "echo $(locations :{}_sh)".format(name)
    #     # cmd_bat="""
    #     # setlocal EnableDelayedExpansion
    #     # for %%f in ($(locations :{}_sh)) do (
    #     #     echo %%f
    #     # )
    #     # """.format(name)
    #     cmd="""
    #     files=($(locations :{}_sh))
    #     EXE=
    #     for f in $${{files[@]}}; do
    #         if [[ $$f == *.exe ]]
    #         then
    #             EXE=$$f
    #         fi
    #     done

    #     echo "cmd /c $${{EXE////\\\\\\}}" > $@
    #     """.format(name),
    # )

    # native.filegroup(
    #     name = name,
    #     srcs = [name + "_bat"],
    #     data = [name + "_sh"],
    # )

    # can use shell to create a batch file

#${A////\\}


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
        #print("full label is a ", native.repository_name() + '//' + native.package_name() + ':' + label)
        return native.repository_name() + '//' + native.package_name() + ':' + label
    else:
        #print("full label is b ", native.repository_name() + '//' + native.package_name() + ':' + label)
        return native.repository_name() + '//' + native.package_name() + ':' + label


# binary is "select()", so cant use that
# Perhaps best to make a custom rule that is basically a reimplementation of genrule except it runs a binary and sets the correct environment variables to include the .so/dll/dylibs


# actually using "$(rootpath)" in blob2 


def test(label):
    #print(Label(full_label(label)).workspace_root)
    return label


# Currently, "bazel run :blob3 --enable_runfiles" works, i just need to somehow get the workspace name programatically