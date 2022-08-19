""" Rule for building pkg-config from sources. """

load("//foreign_cc:defs.bzl", "make_variant")

def pkgconfig_tool(name, srcs, **kwargs):
    tags = ["manual"] + kwargs.pop("tags", [])

    make_variant(
        name = "{}.build".format(name),
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
            "@glib_src//:msvc_hdr"
        ],
        postfix_script = select({
            "@platforms//os:windows": "cp release/x64/pkg-config.exe $$INSTALLDIR$$/bin",
            "//conditions:default": "",
        }),
        toolchain = "@rules_foreign_cc//toolchains:preinstalled_nmake_toolchain",
        tags = tags,
        **kwargs
    )

    # native.filegroup(
    #     name = name,
    #     srcs = ["{}.build".format(name)],
    #     output_group = "gen_dir",
    #     tags = tags,
    # )

    native.filegroup(
        name = name,
        srcs = ["{}.build".format(name)],
        output_group = select({
            "@platforms//os:windows": "pkg-config.exe",
            "//conditions:default": "pkg-config",
        }),
        tags = tags,
    )
