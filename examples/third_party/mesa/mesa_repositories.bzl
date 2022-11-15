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

    # maybe(
    #     http_archive,
    #     name = "bison",
    #     build_file = Label("//mesa:BUILD.bison.bazel"),
    #     sha256 = "06c9e13bdf7eb24d4ceb6b59205a4f67c2c7e7213119644430fe82fbd14a0abb",
    #     strip_prefix = "bison-3.8.2",
    #     url = "https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.gz",
    # )    

    http_archive(
        name = "flex",
        build_file = Label("//mesa:BUILD.flex.bazel"),
        sha256 = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995",
        strip_prefix = "flex-2.6.4",
        url = "https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz",
    )

    maybe(
        http_archive,
        name = "winflexbison",
        build_file = Label("//mesa:BUILD.winflexbison.bazel"),
        sha256 = "8e1b71e037b524ba3f576babb0cf59182061df1f19cd86112f085a882560f60b",
        strip_prefix = "winflexbison-2.5.25",
        url = "https://github.com/lexxmark/winflexbison/archive/refs/tags/v2.5.25.tar.gz",
    )

    maybe(
        http_archive,
        name = "libxcb",
        build_file = Label("//mesa:BUILD.libxcb.bazel"),
        sha256 = "cc38744f817cf6814c847e2df37fcb8997357d72fa4bcbc228ae0fe47219a059",
        strip_prefix = "libxcb-1.15",
        url = "https://xcb.freedesktop.org/dist/libxcb-1.15.tar.xz",
    )

    maybe(
        http_archive,
        name = "xcb-proto",
        build_file = Label("//mesa:BUILD.xcb-proto.bazel"),
        sha256 = "d34c3b264e8365d16fa9db49179cfa3e9952baaf9275badda0f413966b65955f",
        strip_prefix = "xcb-proto-1.15",
        url = "https://xcb.freedesktop.org/dist/xcb-proto-1.15.tar.xz",
    )

    maybe(
        http_archive,
        name = "libxshmfence",
        build_file = Label("//mesa:BUILD.libxshmfence.bazel"),
        sha256 = "7eb3d46ad91bab444f121d475b11b39273142d090f7e9ac43e6a87f4ff5f902c",
        strip_prefix = "libxshmfence-1.3",
        url = "https://www.x.org/releases/individual/lib/libxshmfence-1.3.tar.gz",
    )

