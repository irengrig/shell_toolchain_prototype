load("@generated_toolchain//:commands_toolchain_type_proxy.bzl", "define_variable", "echo")
load("@host_info//:info.bzl", "user")

def _define_and_echo(ctx):
    text = define_variable(ctx, ctx.attr.var_name, ctx.attr.var_value)
    text += "\n" + echo(ctx, "Comment!")

    # We take it until here just for demonstrational reasons
    text += "\n" + "User: " + user

    out = ctx.actions.declare_file("out.txt")

    ctx.actions.write(out, text)

    return [DefaultInfo(files = depset([out]))]

define_and_echo = rule(
    implementation = _define_and_echo,
    attrs = {
        "var_name": attr.string(),
        "var_value": attr.string(),
    },
    toolchains = ["//:commands_toolchain_type"],
)
