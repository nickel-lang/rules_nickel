# Nickel rules for Bazel

These are build rules for generating configuration files using Nickel during a Bazel build.

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
