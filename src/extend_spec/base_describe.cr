module ExtendSpec
  abstract class BaseDescribe
    include Let
    include DefineBlock
    include DefineContext
    include DefineCallbacks
    include TestRunner

    def setup
    end

    def teardown
    end
  end
end