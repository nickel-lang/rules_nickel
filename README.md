# Nickel rules for Bazel

These are build rules for generating configuration files using Nickel during a Bazel build. To use them in a traditional setup with Bazel 6 modules, add the following into your `WORKSPACE` file:

```starlark
http_archive(
  name = "com_github_nickel_lang_rules_nickel",
  # Check for the latest pre-release version
  url = "https://github.com/nickel-lang/rules_nickel/archive/<commit-hash>.zip"
  strip_prefix = "rules_nickel-<commit-hash>",
  sha256 = "<the actual archive hash>",
)
load("@com_github_nickel_lang_rules_nickel//nickel:deps.bzl", "nickel_register_toolchains")
nickel_register_toolchains()
```

## Build Rules

### nickel_export

```starlark
nickel_export(name, src, deps=[], format="json", out)
```

Evaluate a Nickel file and export the result.

| Attribute | Description                                                   |
|-----------|---------------------------------------------------------------|
| `name`    | Unique name for this rule (required)                          |
| `src`     | Nickel file to evaluate (required)                            |
| `deps`    | List of other Nickel files required for evaluation            |
| `format`  | Export format, must be one of `"json", "yaml", "toml", "raw"` |
| `out`     | Output file name (required)                                   |
