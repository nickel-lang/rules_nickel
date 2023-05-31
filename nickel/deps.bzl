load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_nickel_builds = {
    "1.0.0": [
        {
            "os": "linux",
            "arch": "x86_64",
            "url": "https://nickel-static-binaries.s3.eu-central-1.amazonaws.com/nickel-x86_64",
            "sha256": "5ced1ecbdfd28269e851c3b126899f41b8681ec948b2b3b32ae26daa508f6774",
        }
    ]
}

def nickel_register_toolchains(version = "1.0.0"):
    for platform in _nickel_builds[version]:
        http_file(
            name = "nickel_%s_%s" % (platform["os"].lower(), platform["arch"]),
            url = platform["url"],
            executable = True,
            sha256 = platform["sha256"],
        )
