def define_variable(name_, var_):
    return "export {name}=\"{value}\"".format(name = name_, value = var_)

def echo(text):
    return "echo \"{}\"".format(text)

def username():
    return "$USER"
