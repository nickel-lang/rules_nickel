def _nickel_export_impl(ctx):
    args = [
        "export",
        "--file", ctx.file.src.path,
        "--format", ctx.attr.format,
        "--output", ctx.outputs.out.path,
    ]

    ctx.actions.run(
        inputs = [ctx.file.src] + ctx.files.deps,
        outputs = [ctx.outputs.out],
        arguments = args,
        progress_message = "Exporting %s" % ctx.outputs.out.short_path,
        executable = ctx.executable._nickel,
    )

_nickel_export_attrs = {
    "out": attr.output(
        mandatory = True,
    ),
    "src": attr.label(
        doc = "Top-level Nickel file to export from",
        mandatory = True,
        allow_single_file = [".ncl"],
    ),
    "deps": attr.label_list(
        doc = "Nickel files required by the top-level file",
        allow_files = [".ncl"]
    ),
    "format": attr.string(
        doc = "Output format",
        default = "json",
        values = [
            "json",
            "yaml",
            "toml",
            "raw"
        ]
    ),
    "_nickel": attr.label(
        default = Label("//nickel:nickel"),
        executable = True,
        allow_single_file = True,
        cfg = "exec"
    )
}

nickel_export = rule(
    implementation = _nickel_export_impl,
    attrs = _nickel_export_attrs,
)
