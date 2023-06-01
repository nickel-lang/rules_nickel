load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@org_nickel_lang_rules_nickel//nickel:defs.bzl", "nickel_export")

nickel_export(
    name = "test.json",
    src = "test.ncl",
)

build_test(
    name = "smoke_test",
    targets = [
        # targets you add above
        ":export_test",
    ],
)
