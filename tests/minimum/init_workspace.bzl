load("@main//commands_toolchain_def:commands_def.bzl", "PLATFORM_COMMANDS")
load("@main//generation:generate_toolchain.bzl", "generate_toolchain")

def init_workspace():
    generate_toolchain(
        # the name of the repository to generate
        "generated_toolchain",
        # the toolchain type, defined in user's code
        "@//:commands_toolchain_type",
        # the toolchain interface
        PLATFORM_COMMANDS,
        # the toolchain implementation files
        ["@main//toolchain_data:linux_commands.bzl"],
    )
    native.register_toolchains("@//toolchains:all")
