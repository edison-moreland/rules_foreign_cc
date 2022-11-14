"""A module defining the third party dependency zlib"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def mesa_repositories():
    maybe(
        http_archive,
        name = "mesa",
        build_file = Label("//mesa:BUILD.mesa.bazel"),
        sha256 = "670d8cbe8b72902a45ea2da68a9da4dc4a5d99c5953a926177adbce1b1640b76",
        strip_prefix = "mesa-22.1.4",
        url = "https://archive.mesa3d.org//mesa-22.1.4.tar.xz",
    )
    maybe(
        http_archive,
        name = "libpciaccess",
        build_file = Label("//mesa:BUILD.libpciaccess.bazel"),
        sha256 = "84413553994aef0070cf420050aa5c0a51b1956b404920e21b81e96db6a61a27",
        strip_prefix = "libpciaccess-0.16",
        url = "https://www.x.org/archive//individual/lib/libpciaccess-0.16.tar.gz",
    )

    maybe(
        http_archive,
        name = "libdrm",
        build_file = Label("//mesa:BUILD.libdrm.bazel"),
        sha256 = "00b07710bd09b35cd8d80eaf4f4497fe27f4becf467a9830f1f5e8324f8420ff",
        strip_prefix = "libdrm-2.4.112",
        url = "https://dri.freedesktop.org/libdrm/libdrm-2.4.112.tar.xz",
    )

    maybe(
        http_archive,
        name = "winflexbison",
        build_file = Label("//mesa:BUILD.winflexbison.bazel"),
        sha256 = "8e1b71e037b524ba3f576babb0cf59182061df1f19cd86112f085a882560f60b",
        strip_prefix = "winflexbison-2.5.25",
        url = "https://github.com/lexxmark/winflexbison/archive/refs/tags/v2.5.25.tar.gz",
    )

