"""A rule for building projects using the [Meson](https://mesonbuild.com/) build system"""

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
    "expand_locations_and_make_variables",
)
load("//toolchains/native_tools:tool_access.bzl", "get_ninja_data")
load("//foreign_cc/private:make_script.bzl", "pkgconfig_script")
load("@rules_python//python:defs.bzl", "py_binary")

def _meson_priv_impl(ctx):
    """The implementation of the `meson` rule

    Args:
        ctx (ctx): The rule's context object

    Returns:
        list: A list of providers. See `cc_external_rule_impl`
    """

    meson_path = "$EXT_BUILD_ROOT/" + ctx.executable.meson_bin.path

    # TODO - like with cmake (i assume), only add ninja to tool deps if ninja generator is used
    ninja_data = get_ninja_data(ctx)

    # TODO add cmake to the tool_deps, as meson delegates to cmake
    # TODO add pkg-config to tool_deps, should first make built or prebuilt pkg-config toolchain (can download prebuilt artefacts from https://stackoverflow.com/a/1711338 or strawberry perl). If build from source it can be cross-platform

    tools_deps = ctx.attr.tools_deps + [ctx.attr.meson_bin]
    tools_deps += ninja_data.deps

    attrs = create_attrs(
        ctx.attr,
        configure_name = "Meson",
        create_configure_script = _create_meson_script,
        tools_deps = tools_deps,
        meson_path = meson_path,
        ninja_path = ninja_data.path
    )
    return cc_external_rule_impl(ctx, attrs)

def _create_meson_script(configureParameters):
    """Creates the bash commands for invoking commands to build ninja projects

    Args:
        configureParameters (struct): See `ConfigureParameters`

    Returns:
        str: A string representing a section of a bash script
    """
    ctx = configureParameters.ctx
    attrs = configureParameters.attrs
    inputs = configureParameters.inputs

    script = pkgconfig_script(configureParameters.inputs.ext_build_dirs)
    script.append("##export_var## NINJA {}".format(attrs.ninja_path))

    root = detect_root(ctx.attr.lib_source)

    data = ctx.attr.data + ctx.attr.build_data

    # Generate a list of arguments for meson
    generate_args = " ".join([
        ctx.expand_location(arg, data)
        for arg in ctx.attr.generate_args
    ])

    prefix = "{} ".format(expand_locations_and_make_variables(ctx, attrs.tool_prefix, "tool_prefix", data)) if attrs.tool_prefix else ""

    ## TODO - within the builddir, so meson <path to source dir>. need to allow different generators, default should be ninja. only add ninja to action if ninja is used
    # meson is using ninja from /usr/bin, make sure ninja is on the path, like done in cmake.bzl or cmake_script.bzl

    # TODO like with configure_make, get toolchain vars and prepend command:
    #toolchain_vars = get_make_env_vars(workspace_name, tools, flags, env_vars, deps, inputs)
    script.append("{prefix}{meson} --prefix={install_dir} {args} {source_dir}".format(
        prefix = prefix,
        meson = attrs.meson_path,
        install_dir="$$INSTALLDIR$$",
        args = generate_args,
        source_dir = "$$EXT_BUILD_ROOT$$/" + root,
    ))

    build_args = [] + ctx.attr.build_args
    include_dirs = ["$$EXT_BUILD_DEPS$$"] + inputs.include_dirs
    cmake_prefix_path=";".join(include_dirs)
    #build_args.append("--cmake-prefix-path {}".format(cmake_prefix_path))
    # TODO the cmake_prefix_path should include the folder above the "cmake" folder. e.g. for pcre2, CMAKE_PREFIX_PATH=<pcre2 installdir>, not <pcre2 installdir>/cmake

    build_args_str = " ".join([
        ctx.expand_location(arg, data)
        for arg in build_args
    ])


    script.append("{prefix}{meson} compile {args}".format(
        prefix = prefix,
        meson = attrs.meson_path,
        args = build_args_str,
    ))

    if ctx.attr.install:
        install_args = " ".join([
            ctx.expand_location(arg, data)
            for arg in ctx.attr.install_args
        ])
        script.append("{prefix}{meson} install {args}".format(
            prefix = prefix,
            meson = attrs.meson_path,
            args = install_args,
        ))

    return script

def _attrs():
    """Modifies the common set of attributes used by rules_foreign_cc and sets Meson specific attrs

    Returns:
        dict: Attributes of the `meson` rule
    """
    attrs = dict(CC_EXTERNAL_RULE_ATTRIBUTES)

    attrs.update({
        "build_args": attr.string_list(
            doc = "Arguments for the CMake build command",
            mandatory = False,
        ),
        "generate_args": attr.string_list(
            doc = (
                "Arguments for CMake's generate command. Arguments should be passed as key/value pairs. eg: " +
                "`[\"-G Ninja\", \"--debug-output\", \"-DFOO=bar\"]`. Note that unless a generator (`-G`) argument " +
                "is provided, the default generators are [Unix Makefiles](https://cmake.org/cmake/help/latest/generator/Unix%20Makefiles.html) " +
                "for Linux and MacOS and [Ninja](https://cmake.org/cmake/help/latest/generator/Ninja.html) for " +
                "Windows."
            ),
            mandatory = False,
            default = [],
        ),
        "install": attr.bool(
            doc = "If True, the `meson install` comand will be performed after a build",
            default = True,
        ),
        "install_args": attr.string_list(
            doc = "Arguments for the meson install command",
            mandatory = False,
        ),
       "meson_bin": attr.label(
            doc = "Arguments for the meson install command",
            cfg = "exec",
            executable = True,
            mandatory = True,
        ),
        # "install_prefix": attr.string(
        #     doc = (
        #         "Install prefix, i.e. relative path to where to install the result of the build. " +
        #         "Passed as an arg to \"meson\" as --prefix=<install_prefix>."
        #     ),
        #     mandatory = False,
        #     default = "$$INSTALLDIR$$",
        # ),
    })
    return attrs

meson_priv = rule(
    doc = (
        "Rule for building external libraries with [Ninja](https://ninja-build.org/)."
    ),
    attrs = _attrs(),
    fragments = CC_EXTERNAL_RULE_FRAGMENTS,
    output_to_genfiles = True,
    implementation = _meson_priv_impl,
    toolchains = [
        "@rules_foreign_cc//toolchains:ninja_toolchain",
        "@rules_foreign_cc//foreign_cc/private/framework:shell_toolchain",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    # TODO: Remove once https://github.com/bazelbuild/bazel/issues/11584 is closed and the min supported
    # version is updated to a release of Bazel containing the new default for this setting.
    incompatible_use_toolchain_transition = True,
)

def meson(name, requirements=None, **kwargs):
    tags = kwargs.pop("tags", [])

    py_binary(
        name = "meson_for_{}".format(name),
        srcs = [
            "@meson//:meson.py",
        ],
        data = ["@meson//:runtime"],
        python_version = "PY3",
        deps = requirements,
        tags = tags + ["manual"],
        main = "@meson//:meson.py",
    )

    # perhaps rename the rule to _meson
    meson_priv(
        name = name,
        meson_bin = ":meson_for_{}".format(name),
        **kwargs
    )

