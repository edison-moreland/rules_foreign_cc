""" Rule for building pkg-config from sources. """

load("//foreign_cc:defs.bzl", "make_variant")

def pkgconfig_tool(name, srcs, **kwargs):
    tags = ["manual"] + kwargs.pop("tags", [])

    make_variant(
        name = "{}.build".format(name),
        lib_source = srcs,
        args = [
                "-f Makefile.vc",
                "CFG=release"
            ],
        out_binaries = select({
            "@platforms//os:windows": ["pkg-config.exe"],
            "//conditions:default": ["pkg-config"],
        }),
        out_static_libs = [],
        out_shared_libs = [],
        toolchain = "@rules_foreign_cc//toolchains:preinstalled_nmake_toolchain",
        tags = tags,
        **kwargs
    )

    native.filegroup(
        name = name,
        srcs = ["{}.build".format(name)],
        output_group = "gen_dir",
        tags = tags,
    )
