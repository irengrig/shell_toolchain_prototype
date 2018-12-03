load(":my_rule.bzl", "define_and_echo")

toolchain_type(
    name = "commands_toolchain_type",
    visibility = ["//visibility:public"],
)

define_and_echo(
    name = "test",
    var_name = "ABC",
    var_value = "CBA",
)
