"""Extensions for bzlmod.

Installs a Nickel toolchain.
Every module can define a toolchain version under the default name, "nickel".
The latest of those versions will be selected (the rest discarded),
and will always be registered by rules_nickel.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load(":repositories.bzl", "nickel_register_toolchains")
load("//nickel/private:versions.bzl", "TOOL_VERSIONS")

_DEFAULT_NAME = "nickel"
_DEFAULT_VERSION = TOOL_VERSIONS.keys()[0]

nickel_toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one nickel toolchain to be registered.
Overriding the default is only permitted in the root module.
""", default = _DEFAULT_NAME),
    "nickel_version": attr.string(doc = "Explicit version of Nickel.", default = _DEFAULT_VERSION),
    "nickel_opts": attr.string_list(doc = "Nickel root CLI options."),
})

def _toolchain_extension(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != _DEFAULT_NAME and not mod.is_root:
                fail("""\
                Only the root module may override the default name for the nickel toolchain.
                This prevents conflicting registrations in the global namespace of external repos.
                """)
            if toolchain.name not in registrations.keys():
                registrations[toolchain.name] = []
            registrations[toolchain.name].append(
                {
                    "nickel_version": toolchain.nickel_version,
                    "nickel_opts": toolchain.nickel_opts,
                }
            )
    for name, records in registrations.items():
        if len(records) > 1:
            versions = [record["nickel_version"] for record in records]
            # TODO: should be semver-aware, using MVS
            selected_index = versions.index(max(versions))

            # buildifier: disable=print
            print("NOTE: Nickel toolchain {} has multiple records {}, selected {}".format(name, records, records[selected_index]))
        else:
            selected_index = 0

        selected = records[selected_index]
        nickel_register_toolchains(
            name = name,
            nickel_version = selected["nickel_version"],
            nickel_opts = selected["nickel_opts"],
            register = False,
        )

nickel = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": nickel_toolchain},
)
