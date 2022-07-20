load("@bazel_skylib//rules:build_test.bzl", "build_test")

exports_files(
    [
        "BUILD.libdrm.bazel",
    ],
    visibility = ["//visibility:public"],
)

build_test(
    name = "libdrm_build_test",
    targets = [
        "@libdrm//:libdrm",
    ],
    visibility = ["//:__pkg__"],
)
