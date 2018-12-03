def _provider_text(methods):
    return """
WRAPPER = provider(
  doc = "TODO",
  fields = [{}]
)
""".format(", ".join(["\"%s\"" % method_ for method_ in methods]))

def _mapping_text(ids):
    data_ = []
    for id in ids:
        data_ += ["{id} = wrapper_{id}".format(id = id)]
    return "MAPPING = dict(\n{data}\n)".format(data = ",\n".join(data_))

def _toolchain_data_rule_text():
    return """
def _toolchain_data_gen(ctx):
    return platform_common.ToolchainInfo(data = WRAPPER(**MAPPING[ctx.attr.id]))

toolchain_data_gen = rule(
  implementation = _toolchain_data_gen,
  attrs = {
    "id": attr.string()
  }
)
"""

def _toolchain_data_instances_text(ids):
    lines = []
    for id in ids:
        lines += [
            """toolchain_data_gen(
    name = "{id}_toolchain_data",
    id = "{id}",
    visibility = ["//visibility:public"],
)""".format(id = id),
        ]
    return "\n".join(lines)

def _load_and_wrapper_text(id, file_path, methods):
    load_list = ", ".join(["{id}_{method} = \"{method}\"".format(id = id, method = method_) for method_ in methods])
    load_statement = "load(\":{file}\", {list})".format(file = file_path, list = load_list)
    data = ", ".join(["{m} = {id}_{m}".format(id = id, m = method_) for method_ in methods])
    wrapper_statement = "wrapper_{id} = dict({data})".format(id = id, data = data)
    return load_statement + "\n" + wrapper_statement

def _generate_toolchain_data(rctx):
    methods = rctx.attr.methods.keys()
    ids = []
    lines = []
    for file_ in rctx.attr.files:
        id = _id_from_file(file_)
        ids += [id]
        copy = _copy_file(rctx, file_)
        lines += [_load_and_wrapper_text(id, copy, methods)]
    lines += [_mapping_text(ids)]
    lines += [_provider_text(methods)]
    lines += [_toolchain_data_rule_text()]

    rctx.file("toolchain_data_defs.bzl", "\n".join(lines))

    build_text = ["exports_files([\"id_function.bzl\"])"]
    build_text += ["load(\":toolchain_data_defs.bzl\", \"toolchain_data_gen\")"]
    build_text += [_toolchain_data_instances_text(ids)]

    rctx.file(
        "id_function.bzl",
        """
def get_toolchain_data_id(name_):
    (before, middle, after) = name_.partition(".")
    return "@{repo}//:" + before + "_toolchain_data"
""".format(repo = rctx.attr.name),
    )
    toolchain_type_ = str(rctx.attr.toolchain_type)
    rctx.file(rctx.attr.toolchain_type.name + "_proxy.bzl", _access_proxy_text(toolchain_type_, rctx.attr.methods))
    rctx.file("BUILD", "\n".join(build_text))
    rctx.file("WORKSPACE", "workspace(name = \"%s\")" % rctx.attr.name)

def _id_from_file(file_label):
    (before, middle, after) = file_label.name.partition(".")
    return before

def _copy_file(rctx, src):
    src_path = rctx.path(src)
    copy_path = src_path.basename
    rctx.template(copy_path, src_path)
    return copy_path

def _access_proxy_text(toolchain_type_, methods):
    lines = []

    for method_ in methods.keys():
        args_ = methods[method_]
        lines += [
            """def {name}(ctx, {args_}):

  print("{name} was called!!!")

  return ctx.toolchains[\"{t_type}\"].data.{name}({args_})
""".format(name = method_, t_type = toolchain_type_, args_ = ", ".join(args_)),
        ]

    return "\n".join(lines)

generate_toolchain_rule = repository_rule(
    implementation = _generate_toolchain_data,
    attrs = {
        "toolchain_type": attr.label(),
        "methods": attr.string_list_dict(),
        "files": attr.label_list(),
    },
)

def generate_toolchain(name_, toolchain_type_, command_map, impl_files):
    method_args_map = _create_methods_to_args(command_map)
    generate_toolchain_rule(
        name = name_,
        toolchain_type = toolchain_type_,
        methods = method_args_map,
        files = impl_files,
    )

def _create_methods_to_args(command_map):
    dict_ = {}
    for method_ in command_map.keys():
        args = [str(arg_.name) for arg_ in command_map[method_].arguments]
        dict_[method_] = args
    return dict_
