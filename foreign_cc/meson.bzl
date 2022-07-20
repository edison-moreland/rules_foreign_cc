load(":defs.bzl", "ninja")

def meson(name, requirements, **kwargs):
    tags = kwargs.pop("tags", [])

    py_binary(
        name = "meson_for_{}".format(name),
        srcs = [
            "@meson//:meson.py",
        ],
        data = ["@meson//:runtime"],
        python_version = "PY3",
        deps = requirements,
        tags = tags + ["manual"]
    )

    ninja(
        name = name,
        build_data = [
            ":meson_for_{}".format(name),
        ] + kwargs.pop("build_data", []),
        directory = "builddir",
        tool_prefix = kwargs.pop("tool_prefix", "true") + " && OLD_PWD=$$PWD && cd $$EXT_BUILD_ROOT && MESON_FILES=($(locations :meson_for_{})) && MESON_PATH=$$EXT_BUILD_ROOT/$${MESON_FILES[0]} && cd $$OLD_PWD && $$MESON_PATH builddir && ".format(name),
        **kwargs
    )



# have the py_binary src be @meson//:meson.py, and the "data" attr of the py_binary be all the files in the @meson//:mesonbuild dir