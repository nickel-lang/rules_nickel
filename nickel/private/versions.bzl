"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | cut -f1 -d' ' | xxd -r -p | base64
TOOL_VERSIONS = {
    "1.0.0": {
        "x86_64-linux": "sha384-67Pnn8Bukc6vVcL/KCojkqr4d/5p9CMRsXXcyHLFDMlVO7LP/FczKh7oCYarcgdA",
        "arm64-linux": "sha384-7kuG+8lai0+lGs/NvvQK/0EAojNfRf4GLGYmRzROSiEXN8I1nVAAkX3bhwmMtr5j",
    },
}
