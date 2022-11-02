"""Rules for building native build tools such as ninja, make or cmake"""

# buildifier: disable=bzl-visibility
load("//foreign_cc/private:framework.bzl", "expand_locations_and_make_variables")

# buildifier: disable=module-docstring
ToolInfo = provider(
    doc = "Information about the native tool",
    fields = {
        "env": "Environment variables to set when using this tool e.g. M4",
        "path": (
            "Absolute path to the tool in case the tool is preinstalled on the machine. " +
            "Relative path to the tool in case the tool is built as part of a build; the path should be relative " +
            "to the bazel-genfiles, i.e. it should start with the name of the top directory of the built tree " +
            "artifact. (Please see the example `//examples:built_cmake_toolchain`)"
        ),
        "target": (
            "If the tool is preinstalled, must be None. " +
            "If the tool is built as part of the build, the corresponding build target, which should produce " +
            "the tree artifact with the binary to call."
        ),
    },
)

def _native_tool_toolchain_impl(ctx):
    if not ctx.attr.path and not ctx.attr.target:
        fail("Either path or target (and path) should be defined for the tool.")
    path = None
    env = {}
    if ctx.attr.target:
        # print("Command is ", ctx.attr.path)
        _, resolved_bash_command, _ = ctx.resolve_command(
        command = ctx.attr.path,
        # attribute = "command (%s)" % command,
        expand_locations = True,
        make_variables = ctx.attr.env,
        tools = [ctx.attr.target]
        )

        # print("resolved_bash_command is ", resolved_bash_command)
        # print("manifests is ", input_manifests)
        path = resolved_bash_command[-1]

        for k,v in ctx.attr.env.items():
            _, resolved_bash_command, _ = ctx.resolve_command(
            command = v,
            expand_locations = True,
            make_variables = ctx.attr.env,
            tools = [ctx.attr.target]
            )
            env[k] = resolved_bash_command[-1]

    else:
        path = ctx.expand_location(ctx.attr.path)
        env = expand_locations_and_make_variables(ctx, ctx.attr.env, "env", [])
    print("the env is ", env)

    ## TODO on main branch, the env contains EXT_BUILD_ROOT prefix, which wont work in non foreign_cc rules, which is in the intended use case for the current_x_toolchains. First do a PR to just do expand_location, like done for path
    return platform_common.ToolchainInfo(data = ToolInfo(
        env = env,
        path = path,
        target = ctx.attr.target,
    ))

native_tool_toolchain = rule(
    doc = (
        "Rule for defining the toolchain data of the native tools (cmake, ninja), " +
        "to be used by rules_foreign_cc with toolchain types " +
        "`@rules_foreign_cc//toolchains:cmake_toolchain` and " +
        "`@rules_foreign_cc//toolchains:ninja_toolchain`."
    ),
    implementation = _native_tool_toolchain_impl,
    attrs = {
        "env": attr.string_dict(
            doc = "Environment variables to be set when using this tool e.g. M4",
        ),
        "path": attr.string(
            mandatory = False,
            doc = (
                "Absolute path to the tool in case the tool is preinstalled on the machine. " +
                "Relative path to the tool in case the tool is built as part of a build; the path should be " +
                "relative to the bazel-genfiles, i.e. it should start with the name of the top directory " +
                "of the built tree artifact. (Please see the example `//examples:built_cmake_toolchain`)"
            ),
        ),
        "target": attr.label(
            mandatory = False,
            cfg = "exec",
            doc = (
                "If the tool is preinstalled, must be None. " +
                "If the tool is built as part of the build, the corresponding build target, " +
                "which should produce the tree artifact with the binary to call."
            ),
        ),
    },
    incompatible_use_toolchain_transition = True,
)
