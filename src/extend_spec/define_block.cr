module ExtendSpec
  module DefineBlock
    macro define_block(type, description, file, line, end_line, focus, tags, &block)
      class It < {{ @type.id }}
        include ExtendSpec::Fails

        def test_{{ description.strip.gsub(/[^0-9a-zA-Z:]+/, "_").id }}_line_{{line.id}}
          Spec.root_context.{{type.id}}(
            {{description}},
            {{file}},
            {{line}},
            {{end_line}},
            {{focus}},
            {{tags}}
          ) {% if block %} do
            setup
            {{yield}}
          ensure
            teardown
          end {% end %}
        end
      end
    end

    macro it(description = "assert", file = __FILE__, line = __LINE__, end_line = __END_LINE__, focus = false, tags = nil, &block)
      define_block(
        :it, {{description}}, {{file}}, {{line}}, {{end_line}}, {{focus}}, {{tags}}
      ) {% if block %} { {{yield}} } {% end %}
    end

    macro pending(description = "assert", file = __FILE__, line = __LINE__, end_line = __END_LINE__, focus = false, tags = nil, &block)
      define_block(
        :pending, {{description}}, {{file}}, {{line}}, {{end_line}}, {{focus}}, {{tags}}
      ) {% if block %} { {{yield}} } {% end %}
    end
  end
end