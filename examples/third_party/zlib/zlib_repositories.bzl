"""A module defining the third party dependency zlib"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def zlib_repositories():
    maybe(
        http_archive,
        name = "zlib",
        build_file = Label("//zlib:BUILD.zlib.bazel"),
        sha256 = "91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9",
        strip_prefix = "zlib-1.2.12",
        patches = [
            # TODO explain the patch, which is one from vcpkg and a bit more so that on windows generated lib patches pkgconfig pc file, for consumption by dependent rules
            # also say that conan applies a similar patch to solve the same issue
            Label("//zlib:zlib.patch"),

        ],
        urls = [
            "https://zlib.net/zlib-1.2.12.tar.gz",
            "https://storage.googleapis.com/mirror.tensorflow.org/zlib.net/zlib-1.2.12.tar.gz",
        ],
    )
