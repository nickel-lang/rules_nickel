# Nickel rules for Bazel

These are build rules for generating configuration files using Nickel during a Bazel build. To use them in a traditional setup with Bazel 6 modules, add the following into your `WORKSPACE` file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

http_archive(
  name = "com_github_nickel_lang_rules_nickel",
  # Check for the latest pre-release version
  url = "https://github.com/nickel-lang/rules_nickel/archive/7cf7faaad2115bc64c36832b85ba39bcc2002fd5.zip",
  strip_prefix = "rules_nickel-7cf7faaad2115bc64c36832b85ba39bcc2002fd5",
  sha256 = "cad6e88837e4e1a96c939eb14a4fd6afe6d4795f3bf93d2d17cb44a5178bba9c",
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
