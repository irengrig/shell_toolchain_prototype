load(":linux_commands.bzl", linux_commands_define_variable = "define_variable",
linux_commands_echo = "echo", linux_commands_username = "username")

wrapper_linux_commands = dict(
    define_variable = linux_commands_define_variable,
    echo = linux_commands_echo,
    username = linux_commands_username
    )
MAPPING = dict(
    linux = wrapper_linux_commands,
)

def select_implementation(rctx):
    os_name = rctx.os.name
    dict_ = MAPPING[os_name]
    if not dict_:
        fail("No implementations for " + os_name)
    return dict_
