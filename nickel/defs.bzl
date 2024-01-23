"""
To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_nickel//nickel:defs.bzl", ...)
```
"""

load("@bazel_skylib//lib:versions.bzl", "versions")
load("@bazel_skylib//lib:paths.bzl", "paths")

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

def _get_imports(ctx):
    """Gets the imports from a rule's `imports` attribute.

    Args:
        ctx: Rule ctx.

    See Also:
        https://github.com/bazelbuild/rules_python/blob/6695fe1d74d4d13f676213663ff4ab22b3ae2624/python/private/common/common_bazel.bzl#L70C9-L70C9

    Returns:
        List of strings.
    """
    result = []
    for import_str in ctx.attr.imports:
        # Even though `ctx.expand_make_variables` is marked as deprecated,
        # it seems that there is open discussion with correct workaround.
        # See also:
        #   https://github.com/bazelbuild/bazel/issues/5859
        import_str = ctx.expand_make_variables("imports", import_str, {})
        if import_str.startswith("/"):
            continue

        # To prevent "escaping" out of the runfiles tree, we normalize
        # the path and ensure it doesn't have up-level references.
        import_path = paths.normalize(import_str)
        if import_path.startswith("../") or import_path == "..":
            fail("Path '{}' references a path above the execution root".format(
                import_str,
            ))
        result.append(import_path)
    return result

def _nickel_export_impl(ctx):
    nickel = ctx.toolchains["//nickel:toolchain_type"].nickel_info

    args = ctx.actions.args()
    args.add_all([
        "export",
        "--format",
        ctx.attr.format,
    ])

    # Import path support was added in nickel==1.4.0.
    # See also:
    #   https://github.com/tweag/nickel/releases/tag/1.4.0
    if len(ctx.attr.imports) != 0:
        if versions.is_at_least("1.4.0", nickel.version):
            for import_path in _get_imports(ctx):
                args.add_all([
                    "--import-path",
                    import_path,
                ])
        else:
            fail("Nickel<1.4.0 does not support import path specification. Update to new nickel>=1.4.0.")

    # The CLI was changed in nickel==1.3.0.
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
    "imports": attr.string_list(
        doc = """
List of import directories to be passed to `--import-path` .

Subject to "Make variable" substitution. The strings are repo-runfiles-root relative.

Absolute paths (paths that start with `/`) and paths that references a path
above the execution root are not allowed and will result in an error.
""",
    ),
    "deps": attr.label_list(
        doc = "Nickel files required by the top-level file",
        allow_files = [
            ".json",
            ".ncl",
            ".toml",
            ".yaml",
            ".yml",
        ],
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
