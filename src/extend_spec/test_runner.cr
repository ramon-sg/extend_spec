module ExtendSpec
  module TestRunner
    macro __run_all_tests__
      {% for name in @type.methods.map(&.name).select(&.starts_with?("test_")) %}
        {{@type}}.new.{{name}}()
      {% end %}

      {% for sub_class_name in @type.subclasses %}
        if {{sub_class_name}}.is_a?({{@type.id}}.class)
          {{sub_class_name}}.__run_all_tests__
        end
      {% end %}
    end
  end
end