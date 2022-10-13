""" Rule for building pkg-config from sources. """

load("//foreign_cc:defs.bzl", "configure_make","make_variant", "runnable_binary")

def pkgconfig_tool(name, srcs, **kwargs):
    tags = ["manual"] + kwargs.pop("tags", [])

    # # Will need a genrule that uses the current cc toolchain to build pkgconfig. Make sure that when cross compiling that the host is used. Should be, as make_build.bzl refers to current toolchain
    # configure_make(
    #     name = "{}.build".format(name),
    #     configure_options = ["--with-internal-glib"],
    #     lib_name = "pkg-config",
    #     lib_source = srcs,
    #     out_binaries = ["pkg-config"],
    #     tags = tags,
    #     **kwargs
    # )

    # Use genrule rather than configure_make as configure_make depends on pkgconfig toolchain, causing cyclic dependency
    native.genrule(
        name = name,
        outs = ["pkg-config"],
        executable = True,
        srcs= [srcs],
        cmd = """
        ls $(rootpaths {}) | grep configure
        export CC=$(CC)
        ./configure --prefix=$$PWD/install  --with-internal-glib
        $(MAKE)
        $(MAKE) install
        cp $$PWD/install/bin/pkg-config $@
        """.format(srcs),
        toolchains = ["@bazel_tools//tools/cpp:current_cc_toolchain", "@rules_foreign_cc//toolchains:current_make_toolchain"],
        tags = tags,
        **kwargs
    )

    make_variant(
        name = "{}.build_msvc".format(name),
        lib_source = srcs,
        args = [
                "-f Makefile.vc",
                "CFG=release",
                "GLIB_PREFIX=\"$$EXT_BUILD_ROOT/external/glib_dev\""
            ],
        out_binaries = select({
            "@platforms//os:windows": ["pkg-config.exe"],
            "//conditions:default": ["pkg-config"],
        }),
        #TODO change make rule to set the appropriate NMAKE flag when using nmake, rather than cppflags="-I<include dir>"
        env = select({
            "@platforms//os:windows": {"INCLUDE": "$$EXT_BUILD_ROOT/external/glib_src"},
            "//conditions:default": {},
        }),
        out_static_libs = [],
        out_shared_libs = [],
        deps=[
            "@glib_dev",
            "@glib_src//:msvc_hdr",
            "@gettext_runtime"
        ],
        postfix_script = select({
            "@platforms//os:windows": "cp release/x64/pkg-config.exe $$INSTALLDIR$$/bin",
            "//conditions:default": "",
        }),
        toolchain = "@rules_foreign_cc//toolchains:preinstalled_nmake_toolchain",
        tags = tags,
        **kwargs
    )

    # runnable_binary(
    #     name = name,
    #     binary = select({
    #         "@platforms//os:windows": "pkg-config.exe",
    #         "//conditions:default": "pkg-config",
    #     }),
    #     foreign_cc_target = "{}.build".format(name)
    #     # TODO select on msvc. actually only need this on windows
    # )

    # native.filegroup(
    #     name = name,
    #     srcs = ["{}.build".format(name)],
    #     output_group = "gen_dir",
    #     tags = tags,
    # )

    # native.filegroup(
    #     name = name + "_bin",
    #     srcs = ["{}.build".format(name)],
    #     output_group = select({
    #         "@platforms//os:windows": "pkg-config.exe",
    #         "//conditions:default": "pkg-config",
    #     }),
    #     tags = tags,
    # )

    # native.sh_binary(
    #     name = name,
    #     srcs = ["@rules_foreign_cc//foreign_cc/built_tools:pkgconfig_wrapper.sh"],
    #     data = ["{}.build".format(name), name + "_bin"],
    # )
