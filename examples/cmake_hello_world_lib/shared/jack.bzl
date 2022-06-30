load("@rules_foreign_cc//foreign_cc:providers.bzl", "ForeignCcArtifactInfo", "ForeignCcDepsInfo")


def _jack_impl(ctx):
    # print("ForeignCcDepsInfo is ", ctx.attr.target[ForeignCcDepsInfo])
    # print("cmake CcInfo is ", ctx.attr.target[CcInfo].linking_context)
    print("cmake OutputGroupInfo is ", ctx.attr.target[DefaultInfo])

    # print("cc_import CcInfo is ", ctx.attr.targetb[CcInfo].linking_context)
    print("cc_import OutputGroupInfo is ", ctx.attr.targetb[DefaultInfo])

jack = rule(
    attrs = {
        "target": attr.label(),
        "targetb": attr.label(),
    },
    implementation = _jack_impl,
)
