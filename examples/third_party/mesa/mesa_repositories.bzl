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
    # maybe(
    #     http_archive,
    #     name = "winflexbison",
    #     build_file = Label("//mesa:BUILD.winflexbison.bazel"),
    #     sha256 = "8d324b62be33604b2c45ad1dd34ab93d722534448f55a16ca7292de32b6ac135",
    #     url = "https://github.com/lexxmark/winflexbison/releases/download/v2.5.25/win_flex_bison-2.5.25.zip",
    # )
    maybe(
        http_archive,
        name = "winflexbison",
        build_file = Label("//mesa:BUILD.winflexbison.bazel"),
        sha256 = "8e1b71e037b524ba3f576babb0cf59182061df1f19cd86112f085a882560f60b",
        strip_prefix = "winflexbison-2.5.25",
        url = "https://github.com/lexxmark/winflexbison/archive/refs/tags/v2.5.25.tar.gz",
    )

