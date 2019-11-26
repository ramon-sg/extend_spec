module ExtendSpec
  module Methods
  end

  class Spec(T)
    getter described_class = T

    macro let(*names, file = __FILE__, line = __LINE__, &block)
      {% if names.size != 1 %}
        {{ raise "Only one argument can be passed to `let(#{names.join(", ").id})` #{file.id}:#{line.id}" }}
      {% end %}

      getter {{*names}} do
        {{yield}}
      end
    end

    macro let!(*names, &block)
      {% if names.size != 1 %}
        {{ raise "Only one argument can be passed to `let!(#{names.join(", ").id})` #{file.id}:#{line.id}" }}
      {% end %}

      getter({{*names}}) { {{yield}} }

      {% if names.is_a?(TypeDeclaration) %}
        {{names.var.id}}
      {% else %}
        {{names.id}}
      {% end %}
    end

    macro subject(&block)
      getter(subject : T) { {{yield}} }
    end

    macro subject!(&block)
      getter(subject : T) { {{yield}} }
      subject
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
      test_with(:it, {{name}}, {{**options}}) { {{yield}} }
    end

    macro pending(name = "anonymous", **options, &block)
      test_with(:pending, {{name}}, {{**options}}) { {{yield}} }
    end

    macro fail(name = "anonymous", **options, &block)
      test_with(:fail, {{name}}, {{**options}}) { {{yield}} }
    end

    macro test_with(spec_type, name = "anonymous", **options, &block)
      class It < {{ @type.id }}
        def test_{{ name.strip.gsub(/[^0-9a-zA-Z:]+/, "_").id }}_line{{block ? block.line_number : "nn".id}}
          ExtendSpec::Wrapper.{{spec_type.id}}({{name}}, {{**options}}) {% if block %} do {% end %}
            setup
            {{yield}}
          ensure
            teardown
          {% if block %} end {% end %}
        end
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
          .gsub(/[^0-9a-zA-Z]+/, "_")
          .gsub(/^_|_$/, "")
          .split("_").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("")
          .split("::").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("::") \
          + "Line#{block.line_number}"
      %}

      class {{ class_name.id }}Spec < {{ @type }}
        class It < {{ class_name.id }}Spec
          macro finished
            include ExtendSpec::Methods
          end

          SPEC_TEXT = {{text}}
          SPEC_TYPE = {{spec_type}}
        end

        {{ yield }}
      end
    end

    macro __run_tests__
      {% for name in @type.methods.map(&.name).select(&.starts_with?("test_")) %}
        {{@type}}.new.{{name}}
      {% end %}

      {% for sub_class_name in @type.subclasses %}
        {% if sub_class_name.constant("SPEC_TEXT") || sub_class_name.constant("SPEC_TYPE") == nil %}
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