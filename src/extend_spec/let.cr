module ExtendSpec
  module Let
    macro define_let(type, now, name, file, line, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {%
        is_nil = name.type.stringify != "Nil"
        type = name.type
        name = name.var.id
        %}

        @{{name.id}} : {{type}}{%if is_nil %}?{% end %}
        def {{name.id}}
          @{{name.id}} ||= {{yield}}{%if is_nil %}.not_nil!{% end %}
        end
      {% else %}
        def {{name.id}}
          if (value = @{{name.id}}).nil?
            @{{name.id}} = {{yield}}
          else
            value
          end
        end
      {% end %}

      {% if now %}
      def after_initialize
        {% if existing = @type.methods.find { |d| d.name == "after_initialize" } %}
          {{existing.body.id}}
        {% end %}
        {{name.id}}
      end
      {% end %}

      def initialize
        super
        after_initialize
      end

      def after_initialize
      end
    end

    macro let(name, file = __FILE__, line = __LINE__, &block)
      define_let(:let, false, {{name}}, {{file}}, {{line}}) { {{yield}} }
    end

    macro let!(name, file = __FILE__, line = __LINE__, &block)
      define_let(:let, true, {{name}}, {{file}}, {{line}}) { {{yield}} }
    end

    macro subject(var_type = nil, now = false, file = __FILE__, line = __LINE__, &block)
      define_let(
        type: :subject,
        now: false,
        name: subject {% if var_type %}: {{var_type}}{% end %},
        file: {{file}},
        line: {{line}}
      ) { {{yield}} }
    end

    macro subject!(kind = nil, now = false, file = __FILE__, line = __LINE__, &block)
      subject({{kind}}, true, {{file}}, {{line}}) { {{yield}} }
    end
  end
end