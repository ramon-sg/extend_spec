module ExtendSpec
  class Spec(T)
    getter described_class = T

    macro let(*name, &block)
      getter {{*name}} do
        {{yield}}
      end
    end

    macro let!(*name, &block)
      getter({{*name}}) { {{yield}} }

      {% if name.is_a?(TypeDeclaration) %}
        {{name.var.id}}
      {% else %}
        {{name.id}}
      {% end %}
    end

    macro subject(&block)
      let(subject : T) { {{yield}} }
    end

    macro subject!(&block)
      let!(subject : T) { {{yield}} }
    end

    def setup
    end

    def teardown
    end

    macro before(&block)
      def setup
        super()
        {{ yield }}
      end
    end

    macro after(&block)
      def teardown
        {{ yield }}
        super()
      end
    end

    macro it(name = "anonymous", **options, &block)
      def test_{{ name.strip.gsub(/[^0-9a-zA-Z:]+/, "_").id }}_line{{block.line_number}}
        setup
        ExtendSpec::Wrapper.it({{name}}, {{**options}}) { {{yield}} }
      ensure
        teardown
      end
    end

    macro describe(text, &block)
      describe_or_context("describe", {{text}}) { {{yield}} }
    end

    macro context(text, &block)
      describe_or_context("context", {{text}}) { {{yield}} }
    end

    macro describe_or_context(spec_type, text, &block)
      {%
        class_name = text.id.stringify
          .gsub(/[^0-9a-zA-Z:]+/, "_")
          .gsub(/^_|_$/, "")
          .split("_").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("")
          .split("::").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("::") \
          + "Line#{block.line_number}"
      %}

      class {{ class_name.id }}Spec < {{ @type }}
        SPEC_TEXT = {{text}}
        SPEC_TYPE = {{spec_type}}

        {{ yield }}
      end
    end

    macro __run_tests__
      {% for name in @type.methods.map(&.name).select(&.starts_with?("test_")) %}
      {{@type}}.new.{{name}}
      {% end %}

      {% for sub_class_name in @type.subclasses %}
      {% if sub_class_name.constant("SPEC_TEXT") == "" %}
      {{sub_class_name}}.__run_tests__
      {% else %}
      ExtendSpec::Wrapper.{{sub_class_name.constant("SPEC_TYPE").id}} {{sub_class_name.constant("SPEC_TEXT")}} do
        {{sub_class_name}}.__run_tests__
      end
      {% end %}
      {% end %}
    end
  end
end