# extend_spec

A small Crystal shard to extend native spec with:

- No global scope pollution
- No Object pollution
- Add `described_class` method
- Ability to specify `before` and `after` blocks
- Ability to define `let`, `let!`, `subject` and `subject!`

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   development_dependencies:
     extend_spec:
       github: clouw/extend_spec
   ```

2. Run `shards install`

## Usage

Add this to your `spec_helper.cr`:

```crystal
require "extend_spec"
```

## Example

```crystal
class Ninja
  property name : String
  property last_name : String

  def initialize(@last_name, @name)
  end

  def full_name
    "#{last_name} #{name}"
  end
end

describe Ninja do
  let(name) { "Kakashi" }
  let(last_name : String) { "Hatake" }

  subject { described_class.new(last_name, name) }

  describe "#full_name" do
    it "returns full name" do
      subject.full_name.should eq("Hatake Kakashi")
    end

    context "when name change" do
      before { subject.name = "Sakumo" }

      it "returns full name" do
        subject.full_name.should eq("Hatake Sakumo")
      end
    end
  end
end
```

Real example in `spec/dummy_db_spec.cr`

## Contributing

1. Fork it (<https://github.com/clouw/extend_spec/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request