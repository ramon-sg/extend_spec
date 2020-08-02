macro describe(class_or_module, file = __FILE__, line = __LINE__, end_line = __END_LINE__, focus = false, tags = nil, &block)
  {{ class_name = "#{class_or_module}Spec#{line}"  }}
  class {{class_name.id}} < ExtendSpec::BaseDescribe
    alias Described = {{class_or_module}}

    {{yield}}
  end

  Spec.root_context.describe({{class_or_module}}.to_s, {{file}}, {{line}}, {{end_line}}, {{focus}}, {{tags}}) do
    {{class_name.id}}.__run_all_tests__
  end
end