"""
To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_nickel//nickel:defs.bzl", ...)
```
"""

def _nickel_export_impl(ctx):
    nickel = ctx.toolchains["//nickel:toolchain_type"].nickel_info

    args = ctx.actions.args()
    args.add_all([
        "export",
        "--file",
        ctx.file.src.path,
        "--format",
        ctx.attr.format,
    ])

    output = ctx.actions.declare_file(ctx.label.name)
    args.add_all(["--output", output.path])

    ctx.actions.run(
        inputs = [ctx.file.src] + ctx.files.deps,
        outputs = [output],
        arguments = [args],
        progress_message = "Exporting %s" % output.short_path,
        executable = nickel.binary,
        toolchain = "//nickel:toolchain_type",
    )

    return [
        DefaultInfo(
            files = depset([output]),
        ),
    ]

_nickel_export_attrs = {
    "src": attr.label(
        doc = "Top-level Nickel file to export from",
        mandatory = True,
        allow_single_file = [".ncl"],
    ),
    "deps": attr.label_list(
        doc = "Nickel files required by the top-level file",
        allow_files = [".ncl"],
    ),
    "format": attr.string(
        doc = "Output format",
        default = "json",
        values = [
            "json",
            "yaml",
            "toml",
            "raw",
        ],
    ),
}

nickel_export = rule(
    implementation = _nickel_export_impl,
    attrs = _nickel_export_attrs,
    toolchains = ["//nickel:toolchain_type"],
)
