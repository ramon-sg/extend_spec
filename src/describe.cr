macro describe(klass, &block)
  {% class_name = "Spec" + klass.stringify %}

  class {{class_name.id}} < ExtendSpec::Spec({{klass}})
    {{yield}}
  end

  {{class_name.id}}.__run_tests__
end