require "spec"

module ExtendSpec
  module Wrapper
    extend self
    include Spec::Methods
  end
end