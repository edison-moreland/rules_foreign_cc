"""A module defining the third party dependency libgit2"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def glib_repositories():
    maybe(
        http_archive,
        name = "glib",
        build_file = Label("//glib:BUILD.glib.bazel"),
        strip_prefix = "glib-2.75.0",
        sha256 = "6dde8e55cc4a2c83d96797120b08bcffb5f645b2e212164ae22d63c40e0e6360",
        url = "https://download.gnome.org/sources/glib/2.75/glib-2.75.0.tar.xz",
    )
    maybe(
        http_archive,
        name = "libffi",
        build_file = Label("//glib:BUILD.libffi.bazel"),
        strip_prefix = "libffi-meson-3.2.9999.3",
        sha256 = "0113d0f27ffe795158d06f56c9a7340fafc768586095b82a701c687ecb8e3672",
        url = "https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi/-/archive/meson-3.2.9999.3/libffi-meson-3.2.9999.3.tar.gz",
    )
    maybe(
        http_archive,
        name = "gettext",
        build_file = Label("//glib:BUILD.gettext.bazel"),
        sha256 = "0af0a6e2c26dd2c389b4cd5a473e121dad6ddf2f8dca38489c50858c7b8cdd9f",
        url = "https://download.gnome.org/binaries/win64/dependencies/gettext-runtime-dev_0.18.1.1-2_win64.zip",
    )
    # maybe(
    #     http_archive,
    #     name = "gettext_runtime",
    #     build_file = Label("//glib:BUILD.gettext_runtime.bazel"),
    #     sha256 = "1f4269c0e021076d60a54e98da6f978a3195013f6de21674ba0edbc339c5b079",
    #     url = "https://download.gnome.org/binaries/win64/dependencies/gettext-runtime_0.18.1.1-2_win64.zip",
    # )



