"""A module defining convienence methoods for accessing build tools from
rules_foreign_cc toolchains
"""

load(":native_tools_toolchain.bzl", "ToolInfo")

def access_tool(toolchain_type_, ctx, tool_name):
    """A helper macro for getting the path to a build tool's executable

    Args:
        toolchain_type_ (str): The name of the toolchain type
        ctx (ctx): The rule's context object
        tool_name (str): The name of the tool to query

    Returns:
        ToolInfo: A provider containing information about the toolchain's executable
    """
    tool_toolchain = ctx.toolchains[toolchain_type_]
    if tool_toolchain:
        return tool_toolchain.data
    return ToolInfo(
        path = tool_name,
        target = None,
    )

def get_autoconf_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:autoconf_toolchain")), ctx, "autoconf")

def get_automake_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:automake_toolchain")), ctx, "automake")

def get_cmake_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:cmake_toolchain")), ctx, "cmake")

def get_m4_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:m4_toolchain")), ctx, "m4")

def get_make_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:make_toolchain")), ctx, "make")

def get_ninja_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:ninja_toolchain")), ctx, "ninja")

def get_pkgconfig_data(ctx):
    return _access_and_expect_label_copied(str(Label("//toolchains:pkgconfig_toolchain")), ctx, "pkg-config")

def _access_and_expect_label_copied(toolchain_type_, ctx, tool_name):
    tool_data = access_tool(toolchain_type_, ctx, tool_name)
    return struct(
        deps = [] if tool_data.target == None else [tool_data.target],
        # as the tool will be copied into tools directory
        path = tool_data.path if tool_data.target == None else "$EXT_BUILD_ROOT/{}".format(tool_data.path),
    )

def current_native_tool_toolchain(ctx, toolchain):
    default_info = DefaultInfo()
    if toolchain.data.target:
        default_info = DefaultInfo(
            runfiles = ctx.runfiles(
                files = toolchain.data.target.files.to_list(),
            ),
        )

    return [
        toolchain,
        toolchain.make_variables,
        default_info
    ]


# These rules exist so that the current cmake/make/etc toolchain can be used in the `toolchains` attribute of
# other rules, such as genrule. It allows exposing a toolchain after toolchain resolution has
# happened, to a rule which expects a concrete implementation of a toolchain, rather than a
# toochain_type which could be resolved to that toolchain.
#
# See https://github.com/bazelbuild/bazel/issues/14009#issuecomment-921960766
def _current_autoconf_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:autoconf_toolchain"))])

current_autoconf_toolchain_rule = rule(
    implementation = _current_autoconf_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:autoconf_toolchain")),
    ],
)

def _current_automake_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:automake_toolchain"))])

current_automake_toolchain_rule = rule(
    implementation = _current_automake_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:automake_toolchain")),
    ],
)

def _current_cmake_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:cmake_toolchain"))])

current_cmake_toolchain_rule = rule(
    implementation = _current_cmake_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:cmake_toolchain")),
    ],
)

def _current_m4_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:m4_toolchain"))])

current_m4_toolchain_rule = rule(
    implementation = _current_m4_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:m4_toolchain")),
    ],
)

def _current_make_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:make_toolchain"))])

current_make_toolchain_rule = rule(
    implementation = _current_make_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:make_toolchain")),
    ],
)

def _current_ninja_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:ninja_toolchain"))])

current_ninja_toolchain_rule = rule(
    implementation = _current_ninja_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:ninja_toolchain")),
    ],
)

def _current_pkgconfig_toolchain_impl(ctx):
    return current_native_tool_toolchain(ctx, ctx.toolchains[str(Label("//toolchains:pkgconfig_toolchain"))])

current_pkgconfig_toolchain_rule = rule(
    implementation = _current_pkgconfig_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:pkgconfig_toolchain")),
    ],
)
