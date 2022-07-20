"""A module defining the third party dependency libgit2"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def libpciaccess_repositories():
    maybe(
        http_archive,
        name = "libpciaccess",
        build_file = Label("//libpciaccess:BUILD.libpciaccess.bazel"),
        strip_prefix = "libpciaccess-0.16",
        url = "https://www.x.org/archive//individual/lib/libpciaccess-0.16.tar.gz",
        sha256 = "84413553994aef0070cf420050aa5c0a51b1956b404920e21b81e96db6a61a27",
    )
