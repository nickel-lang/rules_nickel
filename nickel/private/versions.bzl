"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "1.0.0": {
        "x86_64-linux": "sha384-fKsrtIzoqBsDe8Kxn5hSxRptbE7RDvgA6AdyAZao1zYCcAgYj6JHM9p/wLOmq6Qi",
    },
}
