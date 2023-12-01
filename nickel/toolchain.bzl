"""This module implements the language-specific toolchain rule.
"""

load("//nickel/private:versions.bzl", "TOOL_VERSIONS")

NickelInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "binary": "Path to the Nickel binary.",
        "version": "Nickel binary version."
    },
)

def _nickel_toolchain_impl(ctx):
    binary = ctx.executable.nickel

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "NICKEL_BIN": binary.path,
    })

    default = DefaultInfo(
        files = depset([binary]),
        runfiles = ctx.runfiles(files = [binary]),
    )
    nickel_info = NickelInfo(
        binary = binary,
        version = ctx.attr.nickel_version
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        nickel_info = nickel_info,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

nickel_toolchain = rule(
    implementation = _nickel_toolchain_impl,
    attrs = {
        "nickel": attr.label(
            doc = "A hermetically downloaded executable target for the build platform.",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "nickel_version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
    },
    doc = """Defines a Nickel toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
