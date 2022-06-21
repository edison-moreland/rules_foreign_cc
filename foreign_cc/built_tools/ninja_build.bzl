""" Rule for building Ninja from sources. """

load(
    "//foreign_cc/built_tools/private:built_tools_framework.bzl",
    "FOREIGN_CC_BUILT_TOOLS_ATTRS",
    "FOREIGN_CC_BUILT_TOOLS_FRAGMENTS",
    "FOREIGN_CC_BUILT_TOOLS_HOST_FRAGMENTS",
    "built_tool_rule_impl",
)
load("//foreign_cc/private/framework:platform.bzl", "os_name")

load(
    "//foreign_cc/private:cc_toolchain_util.bzl",
    "absolutize_path_in_str",
)

def _ninja_tool_impl(ctx):
    py_toolchain = ctx.toolchains["@rules_python//python:toolchain_type"]

    absolute_py_interpreter_path = _absolutize(ctx.workspace_name, py_toolchain.py3_runtime.interpreter.path, True)

    script = [
        "{} ./configure.py --bootstrap".format(absolute_py_interpreter_path),
        "mkdir $$INSTALLDIR$$/bin",
        "cp -p ./ninja{} $$INSTALLDIR$$/bin/".format(
            ".exe" if "win" in os_name(ctx) else "",
        ),
    ]

    return built_tool_rule_impl(
        ctx,
        script,
        ctx.actions.declare_directory("ninja"),
        "BootstrapNinjaBuild",
    )

ninja_tool = rule(
    doc = "Rule for building Ninja. Invokes configure script.",
    attrs = FOREIGN_CC_BUILT_TOOLS_ATTRS,
    host_fragments = FOREIGN_CC_BUILT_TOOLS_HOST_FRAGMENTS,
    fragments = FOREIGN_CC_BUILT_TOOLS_FRAGMENTS,
    output_to_genfiles = True,
    implementation = _ninja_tool_impl,
    toolchains = [
        "@rules_foreign_cc//foreign_cc/private/framework:shell_toolchain",
        "@bazel_tools//tools/cpp:toolchain_type",
        "@rules_python//python:toolchain_type",
    ],
)

# todo commonise
def _absolutize(workspace_name, text, force = False):
    return absolutize_path_in_str(workspace_name, "$$EXT_BUILD_ROOT$$/", text, force)