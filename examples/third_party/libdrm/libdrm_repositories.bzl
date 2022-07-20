"""A module defining the third party dependency libgit2"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def libdrm_repositories():
    maybe(
        http_archive,
        name = "libdrm",
        build_file = Label("//libdrm:BUILD.libdrm.bazel"),
        strip_prefix = "libdrm-2.4.112",
        url = "https://dri.freedesktop.org/libdrm/libdrm-2.4.112.tar.xz",
    )

