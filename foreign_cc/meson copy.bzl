load(":ninja.bzl", "ninja")
load("@rules_python//python:defs.bzl", "py_binary")

# Will the bazel skydocs pick these up, as it isnt a rule, only a macro?
def meson(name, requirements=None, targets=["", "install"], **kwargs):
    tags = kwargs.pop("tags", [])

    py_binary(
        name = "meson_for_{}".format(name),
        srcs = [
            "@meson//:meson.py",
        ],
        data = ["@meson//:runtime"],
        python_version = "PY3",
        deps = requirements,
        tags = tags + ["manual"],
        main = "@meson//:meson.py",
    )

    ninja(
        name = name,
        build_data = [
            ":meson_for_{}".format(name),
        ] + kwargs.pop("build_data", []),
        directory = "builddir",
        tool_prefix = kwargs.pop("tool_prefix", "true") + " && OLD_PWD=$$PWD && cd $$EXT_BUILD_ROOT && " + "MESON_FILES=($(locations :meson_for_{}))".format(name) + " && MESON_PATH=$$EXT_BUILD_ROOT/$${MESON_FILES[0]} && cd $$OLD_PWD && $$MESON_PATH --prefix=$$INSTALLDIR builddir &&",
        targets = targets,
        **kwargs
    )



# have the py_binary src be @meson//:meson.py, and the "data" attr of the py_binary be all the files in the @meson//:mesonbuild dir