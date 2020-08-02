module ExtendSpec
  module Fails
    {% for method in %w(it context describe let subject before after) %}
      {{ message = "`{{ method.id }}` is not available from within an example (e.g. an `it` block)" }}
      {% if method != "subject" %}
      def {{ method.id }}(text = nil, file = __FILE__, line = __LINE__)
        fail({{ message }}, file, line)
      end
      {% end %}

      def {{ method.id }}(text = nil, file = __FILE__, line = __LINE__, &block)
        fail({{ message }}, file, line)
      end
    {% end %}
  end
end