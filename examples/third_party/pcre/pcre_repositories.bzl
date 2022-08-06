"""A module defining the third party dependency PCRE"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def pcre_repositories():
    maybe(
        http_archive,
        name = "pcre",
        build_file = Label("//pcre:BUILD.pcre.bazel"),
        strip_prefix = "pcre2-10.40",
        sha256 = "ded42661cab30ada2e72ebff9e725e745b4b16ce831993635136f2ef86177724",
        urls = [
            "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz",
        ],
    )
