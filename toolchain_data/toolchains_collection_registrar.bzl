def register_toolchains_in_build_file(toolchain_type_, toolchain_data_fun):
    native.toolchain(
        name = "linux_toolchain",
        toolchain_type = toolchain_type_,
        toolchain = toolchain_data_fun("linux_commands.bzl"),
    )
