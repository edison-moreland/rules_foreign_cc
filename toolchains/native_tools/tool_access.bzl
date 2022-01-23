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

def _get_full_tool_path(tool_data):
    '''
        Returns the path to the tool relative to the bazel exec root
    '''

    # This could be made more efficient by changing the
    # toolchain to provide the executable as a target
    cmd_file = tool_data
    for f in tool_data.target.files.to_list():
        if f.path.endswith("/" + tool_data.path):
            return f.path
    return None

def _access_and_expect_label_copied(toolchain_type_, ctx, tool_name):
    tool_data = access_tool(toolchain_type_, ctx, tool_name)
    if tool_data.target:
        cmd_file_path = _get_full_tool_path(tool_data)
        if cmd_file_path == None:
            cmd_file_path = tool_data.path

        return struct(
            deps = [tool_data.target],
            # as the tool will be copied into tools directory
            path = "$EXT_BUILD_ROOT/{}".format(cmd_file_path),
        )
    else:
        return struct(
            deps = [],
            path = tool_data.path,
        )




def _current_cmake_toolchain_impl(ctx):
    toolchain = ctx.toolchains[str(Label("//toolchains:cmake_toolchain"))]

    # TODO need to cater for preinstalled tools, ie where "target" is not set

    #print(toolchain.data.target.files)

    cmake_data = get_cmake_data(ctx)
    tool_data = access_tool(str(Label("//toolchains:cmake_toolchain")), ctx, "cmake")
    tool_data_path = _get_full_tool_path(tool_data)
    #print((tool_data))

    make_variables = platform_common.TemplateVariableInfo({
        "CMAKE_EXE": tool_data_path,
    })


    return [
        toolchain,
        make_variables,
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = toolchain.data.target.files.to_list(),
                #files = cmake_data.deps,
            ),
        ),
    ]

# This rule exists so that the current perl toolchain can be used in the `toolchains` attribute of
# other rules, such as genrule. It allows exposing a perl_toolchain after toolchain resolution has
# happened, to a rule which expects a concrete implementation of a toolchain, rather than a
# toochain_type which could be resolved to that toolchain.
#
# See https://github.com/bazelbuild/bazel/issues/14009#issuecomment-921960766
current_cmake_toolchain_rule = rule(
    implementation = _current_cmake_toolchain_impl,
    toolchains = [
        str(Label("//toolchains:cmake_toolchain")),
    ],
)