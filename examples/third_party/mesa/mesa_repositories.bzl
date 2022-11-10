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
