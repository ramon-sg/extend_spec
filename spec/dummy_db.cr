require "json"

class DummyDB
  alias Store = Hash(String, String)

  getter store = Store.new

  property dir : String
  property name : String

  def initialize(@dir, @name)
  end

  def set(key, value)
    @store[key] = value
  end

  def path
    File.join(dir, name)
  end

  def save
    File.write(path, store.to_json)
  end

  def load
    @store = Store.from_json(File.read(path))
  end
end