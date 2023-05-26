def _nickel_export(ctx):
    fail("TODO: nickel_export")

def _nickel_export_outputs(src, output_name, output_format):
    outputs = {
        "export": output_name
    }
    return outputs

_nickel_export_attrs = {
    "src": attr.label(
        doc = "Nickel file to export",
        mandatory = True,
        allow_single_file = [".ncl"],
    ),
    "output_name": attr.string(
        doc = "Name of the output file",
        mandatory = True,
    ),
    "output_format": attr.string(
        doc = "Output format",
        default = "json",
        values = [
            "json",
            "yaml",
            "toml",
            "raw"
        ]
    ),
}

nickel_export = rule(
    implementation = _nickel_export,
    attrs = _nickel_export_attrs,
    outputs = _nickel_export_outputs,
)