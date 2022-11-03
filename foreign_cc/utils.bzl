""" This file contains useful utilities """

def _full_label(label):
    return native.repository_name() + "//" + native.package_name() + ":" + label

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
        match_binary_name: True if the generated runnable file should have the same name as the provided "binary" argument. This is useful when the runnable_binary is used with tools that expect a certain filename, e.g tools like CMake and Meson expect "pkg-config" to be on the PATH
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
    )

    native.genrule(
        name = name + "_wrapper",
        srcs = ["@rules_foreign_cc//foreign_cc/private:runnable_binary_wrapper.sh", name + "_fg"],
        outs = [name + "_wrapper.sh"],
        cmd = "sed s@BIN@$(rootpath {})@g $(location @rules_foreign_cc//foreign_cc/private:runnable_binary_wrapper.sh) > $@".format(_full_label(name + "_fg")),
        tags = tags + ["manual"],
    )

    native.sh_binary(
        name = binary if match_binary_name else name,
        deps = ["@bazel_tools//tools/bash/runfiles"],
        data = [name + "_fg", foreign_cc_target],
        srcs = [name + "_wrapper"],
        tags = tags + ["manual"],
        **kwargs
    )

    if match_binary_name:
        native.alias(
            name = name,
            actual = binary,
            **kwargs,
        )