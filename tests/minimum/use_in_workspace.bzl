load("@main//toolchain_data:workspace_toolchain_selector.bzl", "select_implementation")

def _use_shell_toolchain(rctx):
    dict_ = select_implementation(rctx)
    echo_fun = dict_["echo"]
    username_fun = dict_["username"]

    text_ = username_fun()
    result = cmd(rctx, "{}".format(echo_fun(text_)))

    print("From repository rule: " + result)

    rctx.file("info.bzl", "user = \"{}\"".format(result))
    rctx.file("BUILD", "[export_files = [\"info.bzl\"]]")

use_shell_toolchain = repository_rule(
    implementation = _use_shell_toolchain,
)

def cmd(
        repository_ctx,
        command,
        environment = None):
    """Execute a command, return stdout if succeed and throw an error if it fails. Doesn't escape the result!"""
    if environment:
        result = repository_ctx.execute(["bash", "-c", command], environment = environment)
    else:
        result = repository_ctx.execute(["bash", "-c", command])
    if result.return_code != 0:
        fail("non-zero exit code: %d, command %s, stderr: (%s)" % (
            result.return_code,
            command,
            result.stderr,
        ))
    stripped_stdout = result.stdout.strip()
    if not stripped_stdout:
        fail(
            "empty output from command %s, stderr: (%s)" % (command, result.stderr),
        )
    return stripped_stdout
