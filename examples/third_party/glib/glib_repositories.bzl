"""A module defining the third party dependency libgit2"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def glib_repositories():
    maybe(
        http_archive,
        name = "glib",
        build_file = Label("//glib:BUILD.glib.bazel"),
        strip_prefix = "glib-2.73.2",
        sha256 = "5f3ee36e34f4aaab393c3e3dc46fb01b32f7ead6c88d41d7f20d88a49cdef1d9",
        url = "https://download.gnome.org/sources/glib/2.73/glib-2.73.2.tar.xz",
    )
    maybe(
        http_archive,
        name = "libffi",
        build_file = Label("//glib:BUILD.libffi.bazel"),
        strip_prefix = "libffi-meson-3.2.9999.3",
        sha256 = "0113d0f27ffe795158d06f56c9a7340fafc768586095b82a701c687ecb8e3672",
        url = "https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi/-/archive/meson-3.2.9999.3/libffi-meson-3.2.9999.3.tar.gz",
    )

