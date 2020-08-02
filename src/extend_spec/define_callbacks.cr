module ExtendSpec
  module DefineCallbacks
    macro callback(name, file, line, &block)
      def {{name.id}}
        {% if existing = @type.methods.find { |d| d.name == name } %}
        {{existing.body.id}}
        {% else %}
        super
        {% end %}

        {{yield}}
      end
    end

    macro before(file = __FILE__, line = __LINE__, &block)
      callback(:setup, {{file}}, {{line}}) {{block}}
    end

    macro after(file = __FILE__, line = __LINE__, &block)
      callback(:teardown, {{file}}, {{line}}) {{block}}
    end
  end
end