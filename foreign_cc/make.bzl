"""A rule for building projects using the [GNU Make](https://www.gnu.org/software/make/) build tool"""

load(
    "//foreign_cc/private:cc_toolchain_util.bzl",
    "get_flags_info",
    "get_tools_info",
)
load(
    "//foreign_cc/private:detect_root.bzl",
    "detect_root",
)
load(
    "//foreign_cc/private:framework.bzl",
    "CC_EXTERNAL_RULE_ATTRIBUTES",
    "CC_EXTERNAL_RULE_FRAGMENTS",
    "cc_external_rule_impl",
    "create_attrs",
    "expand_locations",
)
load("//foreign_cc/private:make_script.bzl", "create_make_script")
load("//foreign_cc/private/framework:platform.bzl", "os_name")
load("//foreign_cc/private:transitions.bzl", _make_variant = "make_variant")
load("//toolchains/native_tools:tool_access.bzl", "get_make_data")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_skylib//lib:paths.bzl", "paths")


def _make(ctx):
    make_data = get_make_data(ctx)

    tools_deps = ctx.attr.tools_deps + make_data.deps

    attrs = create_attrs(
        ctx.attr,
        configure_name = "Make",
        create_configure_script = _create_make_script,
        tools_deps = tools_deps,
        make_path = make_data.path,
    )
    return cc_external_rule_impl(ctx, attrs)

def _create_make_script(configureParameters):
    ctx = configureParameters.ctx
    attrs = configureParameters.attrs
    inputs = configureParameters.inputs

    root = detect_root(ctx.attr.lib_source)

    tools = get_tools_info(ctx)
    flags = get_flags_info(ctx)

    #print("flags are", flags)
    cc_toolchain = find_cpp_toolchain(ctx)
    print("ld exec is ", cc_toolchain.ld_executable)

    data = ctx.attr.data + ctx.attr.build_data

    # Generate a list of arguments for make
    args = " ".join([
        ctx.expand_location(arg, data)
        for arg in ctx.attr.args
    ])

    make_commands = []
    ## TODO change this to instead check if we are using msvc
    if "win" in os_name(ctx):
        # Prepend PATH environment variable with the path to the toolchain linker, which prevents MSYS using its linker (/usr/bin/link.exe) rather than the MSVC linker (both are named "link.exe")
        linker_path = paths.dirname(cc_toolchain.ld_executable)

        # Change prefix of linker path from Windows style to Unix style, required by MSYS. E.g. change "C:" to "/c"
        if linker_path[0].isalpha() and linker_path[1] == ":":
            linker_path = linker_path.replace(linker_path[0:2], "/" + linker_path[0].lower())

        # MSYS requires pahts containing whitespace to be wrapped in quotation marks
        make_commands.append("export PATH=\"" + linker_path + "\":$PATH")

    prefix = "{} ".format(expand_locations(attrs.tool_prefix, data)) if attrs.tool_prefix else ""
    for target in ctx.attr.targets:
        make_commands.append("{prefix}{make} -C $$EXT_BUILD_ROOT$$/{root} {target} {args}".format(
            prefix = prefix,
            make = attrs.make_path,
            root = root,
            args = args,
            target = target,
        ))

    return create_make_script(
        root = root,
        inputs = inputs,
        make_commands = make_commands,
    )

def _attrs():
    attrs = dict(CC_EXTERNAL_RULE_ATTRIBUTES)
    attrs.update({
        "args": attr.string_list(
            doc = "A list of arguments to pass to the call to `make`",
        ),
        "targets": attr.string_list(
            doc = (
                "A list of targets within the foreign build system to produce. An empty string (`\"\"`) will result in " +
                "a call to the underlying build system with no explicit target set"
            ),
            mandatory = False,
            default = ["", "install"],
        ),
    })
    return attrs

make = rule(
    doc = (
        "Rule for building external libraries with GNU Make. " +
        "GNU Make commands (make and make install by default) are invoked with prefix=\"install\" " +
        "(by default), and other environment variables for compilation and linking, taken from Bazel C/C++ " +
        "toolchain and passed dependencies."
    ),
    attrs = _attrs(),
    fragments = CC_EXTERNAL_RULE_FRAGMENTS,
    output_to_genfiles = True,
    implementation = _make,
    toolchains = [
        "@rules_foreign_cc//toolchains:make_toolchain",
        "@rules_foreign_cc//foreign_cc/private/framework:shell_toolchain",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    # TODO: Remove once https://github.com/bazelbuild/bazel/issues/11584 is closed and the min supported
    # version is updated to a release of Bazel containing the new default for this setting.
    incompatible_use_toolchain_transition = True,
)

def make_variant(name, toolchain, **kwargs):
    """ Wrapper macro around the make() rule to force usage of the given make variant toolchain.

    Args:
        name: The target name
        toolchain: The desired make variant toolchain to use, e.g. @rules_foreign_cc//toolchains:preinstalled_nmake_toolchain
        **kwargs: Remaining keyword arguments
    """
    _make_variant(
        name = name,
        rule = make,
        toolchain = toolchain,
        **kwargs
    )
