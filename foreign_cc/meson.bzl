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
load("//toolchains/native_tools:tool_access.bzl", "get_ninja_data", "get_meson_data")
load("//foreign_cc/private:make_script.bzl", "pkgconfig_script")
load("@rules_python//python:defs.bzl", "py_binary")
load("//foreign_cc/built_tools:meson_build.bzl", "meson_tool")
load("//toolchains/native_tools:native_tools_toolchain.bzl", "native_tool_toolchain")
load("//foreign_cc/private:transitions.bzl", "foreign_cc_rule_variant")
load("//foreign_cc:utils.bzl", "full_label")


def _meson_impl(ctx):
    """The implementation of the `meson` rule

    Args:
        ctx (ctx): The rule's context object

    Returns:
        list: A list of providers. See `cc_external_rule_impl`
    """

    meson_data = get_meson_data(ctx)
    # meson_zip_file = ctx.attr.meson_bin[OutputGroupInfo].python_zip_file.to_list()[0].path
    # TODO if --nobuild_python_zip, perhaps the python_zip_file is None or doesn't exist (can do hasattr())
    # :[PyInfo, PyRuntimeInfo, InstrumentedFilesInfo, PyCcLinkParamsProvider, OutputGroupInfo]>
    # TODO - could extract the zip file, use "sed" to change is PythonZip to return False, mv "runfiles" to __main__.py.exe.runfiles.
    # This is turning into a lot of effort for just glib, perhaps rules_foreign_cc just sets enable_runfiles, no_python_zip and windows_enable_symlinks
    # rules_foreign_cc CI could build libffi with a python zip and glib without one

    # TODO move the logic of getting python interpreter path up to here
    # meson_path = "$EXT_BUILD_ROOT/" + meson_zip_file
    # meson_path = "$EXT_BUILD_ROOT/" + ctx.executable.meson_bin.path

    # TODO - like with cmake (i assume), only add ninja to tool deps if ninja generator is used
    ninja_data = get_ninja_data(ctx)

    # TODO add cmake to the tool_deps, as meson delegates to cmake. Does meson support pure "make" builds? if so, add "make" to tool deps
    # TODO add pkg-config to tool_deps, should first make built or prebuilt pkg-config toolchain (can download prebuilt artefacts from https://stackoverflow.com/a/1711338 or strawberry perl). If build from source it can be cross-platform
    # TODO ensure cppflags and ldflags are set correctly so that deps are included. How does CMake rule do it for libs that don't generate a pkgconfig?

    tools_deps = ctx.attr.tools_deps + meson_data.deps + ninja_data.deps
    

    attrs = create_attrs(
        ctx.attr,
        configure_name = "Meson",
        create_configure_script = _create_meson_script,
        tools_deps = tools_deps,
        meson_path = meson_data.path,
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

    # Could just not bother with pkgconfig and cmake here and let target devs do it
    # ext_build_dir is like external/zlib/copy_zlibb/zlibb, so
    # external/<repo name>/copy_<target name>/<target name>
    # Or just fix zlib so that on windows the output matches pkgconfig, i.e the patch that vcpkg applies and remove if(UNIX). In fact this is better because what if @zlib is used in a configure_make rule?
    script = pkgconfig_script(configureParameters.inputs.ext_build_dirs)

    # do a "git grep" in meson source code repo for cmake and pkg config variables and set them also, like how NINJA is set below. Have a comment linking to this part of the meson source code to say that these variables can be used
    script.append("##export_var## NINJA {}".format(attrs.ninja_path))

    root = detect_root(ctx.attr.lib_source)

    data = ctx.attr.data + ctx.attr.build_data

    # Generate a list of arguments for meson
    options_str = " ".join([
        "-D{}=\"{}\"".format(key, ctx.attr.options[key])
        for key in ctx.attr.options
    ])

    prefix = "{} ".format(expand_locations_and_make_variables(ctx, attrs.tool_prefix, "tool_prefix", data)) if attrs.tool_prefix else ""

    py_interpreter = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"].py3_runtime.interpreter.path
    # TODO use absolutze function that is elsehwere in this repo
    py_interpreter_absolute = "$$EXT_BUILD_ROOT$$/" + py_interpreter

    # TODO - dont do the above if nobuild_python_zip is used, dont know how to check for arg inside a rule. actually doing python.exe <path to zip> didnt fix the problem, so above logic isnt necessary

    ## TODO - within the builddir, so meson <path to source dir>. need to allow different generators, default should be ninja. only add ninja to action if ninja is used
    # meson is using ninja from /usr/bin, make sure ninja is on the path, like done in cmake.bzl or cmake_script.bzl

    # TODO like with configure_make, get toolchain vars and prepend command:
    #toolchain_vars = get_make_env_vars(workspace_name, tools, flags, env_vars, deps, inputs)
    script.append("{prefix}{meson} --prefix={install_dir} {options} {source_dir}".format(
        prefix = prefix,
        # TODO have this logic of adding these paths and explain why
        # meson = py_interpreter_absolute + " " + attrs.meson_path,
        meson = attrs.meson_path,
        install_dir="$$INSTALLDIR$$",
        options = options_str,
        source_dir = "$$EXT_BUILD_ROOT$$/" + root,
    ))

    build_args = [] + ctx.attr.build_args
    include_dirs = ["$$EXT_BUILD_DEPS$$"] + inputs.include_dirs
    cmake_prefix_path=";".join(include_dirs)
    #build_args.append("--cmake-prefix-path {}".format(cmake_prefix_path))
    # TODO the cmake_prefix_path should include the folder above the "cmake" folder. e.g. for pcre2, CMAKE_PREFIX_PATH=<pcre2 installdir>, not <pcre2 installdir>/cmake
    # can have args to meson rule to exclude certain deps from pkg config path or cmake prefix path

    build_args_str = " ".join([
        ctx.expand_location(arg, data)
        for arg in build_args
    ])

    script.append("{prefix}{meson} compile {args}".format(
        prefix = prefix,
        # meson = py_interpreter_absolute + " " + attrs.meson_path,
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
            #meson = py_interpreter_absolute + " " + attrs.meson_path,
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
        "install": attr.bool(
            doc = "If True, the `meson install` comand will be performed after a build",
            default = True,
        ),
        "install_args": attr.string_list(
            doc = "Arguments for the meson install command",
            mandatory = False,
        ),
        "options": attr.string_dict(
            doc = (
                "Meson option entries to initialize (they will be passed with `-Dkey=value`)"
            ),
            mandatory = False,
            default = {},
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

meson = rule(
    doc = (
        "Rule for building external libraries with [Ninja](https://ninja-build.org/)."
        # TODO update this documentation and say that windows requires --enable_runfiles
    ),
    attrs = _attrs(),
    fragments = CC_EXTERNAL_RULE_FRAGMENTS,
    output_to_genfiles = True,
    implementation = _meson_impl,
    toolchains = [
        "@rules_foreign_cc//toolchains:meson_toolchain",
        "@rules_foreign_cc//toolchains:ninja_toolchain",
        "@rules_foreign_cc//foreign_cc/private/framework:shell_toolchain",
        "@bazel_tools//tools/cpp:toolchain_type",
        # TODO - required to prevent extract of python zipper into tmpdir that is later removed, may not work tho
        "@bazel_tools//tools/python:toolchain_type"
    ],
    # TODO: Remove once https://github.com/bazelbuild/bazel/issues/11584 is closed and the min supported
    # version is updated to a release of Bazel containing the new default for this setting.
    incompatible_use_toolchain_transition = True,
)


def meson_with_requirements(name, requirements, **kwargs):
    """ Wrapper macro around foreign cc rules to force usage of the given make variant toolchain.

    Args:
        name: The target name
        rule: The foreign cc rule to instantiate, e.g. configure_make
        toolchain: The desired make variant toolchain to use, e.g. @rules_foreign_cc//toolchains:preinstalled_nmake_toolchain
        **kwargs: Remaining keyword arguments
    """
    tags = kwargs.pop("tags", [])


    meson_tool(
        name = "meson_tool_for_{}".format(name),
        main = "@meson_src//:meson.py",
        data = ["@meson_src//:runtime"],
        requirements = requirements,
        tags = tags + ["manual"],
    )

    native_tool_toolchain(
        name = "built_meson_for_{}".format(name),
        env = {"MESON": "$(execpath :meson_tool_for_{})".format(name)},
        path = "$(execpath :meson_tool_for_{})".format(name),
        target = ":meson_tool_for_{}".format(name),
    )

    native.toolchain(
        name = "built_meson_toolchain_for_{}".format(name),
        toolchain = "built_meson_for_{}".format(name),
        toolchain_type = "@rules_foreign_cc//toolchains:meson_toolchain",
    )

    foreign_cc_rule_variant(
        name = name,
        rule = meson,
        toolchain = full_label("built_meson_toolchain_for_{}".format(name)),
        # toolchain = "@rules_foreign_cc//toolchains:built_meson_toolchain",
        **kwargs
    )
