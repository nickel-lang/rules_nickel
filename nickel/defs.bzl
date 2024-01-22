"""
To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_nickel//nickel:defs.bzl", ...)
```
"""

load("@bazel_skylib//lib:versions.bzl", "versions")

def _collect_runfiles(ctx, direct_files, indirect_targets):
    """Builds a runfiles object for the current target.

    Source:
      https://github.com/jayconrod/rules_go_simple/blob/43b692d481140486513b00f862fbde9938f90a77/internal/rules.bzl#L323

    Args:
        ctx: analysis context.
        direct_files: list of Files to include directly.
        indirect_targets: list of Targets to gather transitive runfiles from.
    Returns:
        A runfiles object containing direct_files and runfiles from
        indirect_targets. The files from indirect_targets won't be included
        unless they are also included in runfiles.
    """
    return ctx.runfiles(
        files = direct_files,
        # Note that we are using `data_runfiles` rather than `default_runfiles`.
        # Even though, this is in contrary with the bazel third recomendation from [1],
        # `filegroup` rule does NOT respect the fact that `srcs` should be added also
        # to the `default_runfiles`.
        # [1] https://bazel.build/extending/rules#runfiles_features_to_avoid
        transitive_files = depset(
            transitive = [target[DefaultInfo].data_runfiles.files for target in indirect_targets],
        ),
    )

def _nickel_export_impl(ctx):
    nickel = ctx.toolchains["//nickel:toolchain_type"].nickel_info

    args = ctx.actions.args()
    args.add_all([
        "export",
        "--format",
        ctx.attr.format,
    ])

    # The CLI was changed in nickel==1.3.0, therefore we need to branch
    # based on the nickel toolchain version.
    # See also:
    #   https://github.com/tweag/nickel/releases/tag/1.3.0
    if versions.is_at_least("1.3.0", nickel.version):
        args.add_all(
            [f.path for f in ctx.files.srcs],
        )
    else:
        if len(ctx.files.srcs) != 1:
            fail("Nickel<1.3.0 does not support multiple files argument. Update to new nickel>=1.3.0, or perform the merge explicitly.")
        args.add_all([
            "--file",
            ctx.files.srcs[0].path,
        ])

    output = ctx.actions.declare_file(ctx.label.name)
    args.add_all(["--output", output.path])

    runfiles = _collect_runfiles(
        ctx,
        direct_files = ctx.files.deps + ctx.files.srcs,
        indirect_targets = ctx.attr.deps,
    )

    ctx.actions.run(
        inputs = runfiles.files,
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
    "srcs": attr.label_list(
        doc = "Top-level Nickel file to export from",
        mandatory = True,
        allow_files = [".ncl"],
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
