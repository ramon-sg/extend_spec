module ExtendSpec
  module DefineContext
    macro define_context(type, description, file, line, end_line, focus, tags, &block)
      {%
        class_name = description.id.stringify
          .gsub(/[^0-9a-zA-Z]+/, "_")
          .gsub(/^_|_$/, "")
          .split("_").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("")
          .split("::").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("::") \
          + "Line#{line}"
      %}

      class {{ class_name.id }}Spec < {{ @type }}
        SPEC_DESCRIPTION = {{description}}
        SPEC_TYPE = {{type}}
        SPEC_FOCUS = {{focus}}
        SPEC_TAGS = {{tags}}

        {{ yield }}
      end
    end

    macro describe(description, file = __FILE__, line = __LINE__, end_line = __END_LINE__, focus = false, tags = nil, &block)
      define_context(
        :describe, {{description}}, {{file}}, {{line}}, {{end_line}}, {{focus}}, {{tags}}
      ) {% if block %} { {{yield}} } {% end %}
    end

    macro context(description, file = __FILE__, line = __LINE__, end_line = __END_LINE__, focus = false, tags = nil, &block)
      define_context(
        :context, {{description}}, {{file}}, {{line}}, {{end_line}}, {{focus}}, {{tags}}
      ) {% if block %} { {{yield}} } {% end %}
    end
  end
end