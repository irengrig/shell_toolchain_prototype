load("//generation:types.bzl", "ArgumentInfo", "CommandInfo")

PLATFORM_COMMANDS = {
    "define_variable": CommandInfo(
        arguments = [
            ArgumentInfo(name = "name", type = type(""), doc = "Variable name"),
            ArgumentInfo(name = "value", type = type(""), doc = "Variable value"),
        ],
        doc = "Defines and exports environment variable.",
    ),
    "echo": CommandInfo(
        arguments = [
            ArgumentInfo(name = "text", type = type(""), doc = "Echo argument"),
        ],
        doc = "Echoes the passed value.",
    ),
    "username": CommandInfo(
        arguments = [],
        doc = "Returns the username variable name.",
    ),
}
