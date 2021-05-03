"""A module defining the third party dependency apr"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def apr_repositories():
    maybe(
        http_archive,
        name = "apr",
        build_file = Label("//apr:BUILD.apr.bazel"),
        # Apply patch from https://bz.apache.org/bugzilla/show_bug.cgi?id=50146
        patches = [ Label("//apr:macos.patch") ],
        sha256 = "48e9dbf45ae3fdc7b491259ffb6ccf7d63049ffacbc1c0977cced095e4c2d5a2",
        strip_prefix = "apr-1.7.0",
        urls = [
            "https://www-eu.apache.org/dist//apr/apr-1.7.0.tar.gz",
        ],
    )
