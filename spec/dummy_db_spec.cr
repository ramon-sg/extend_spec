require "./spec_helper"

describe DummyDB do
  let(name) { "prod.db" }
  let(dir : String) { File.tempname }

  subject { described_class.new(dir, name) }

  before { Dir.mkdir dir }
  after { FileUtils.rm_rf dir }

  it { subject.should be_a(DummyDB) }

  describe "#name" do
    it { subject.name.should eq(name) }
  end

  describe "#set" do
    it "saves value" do
      subject.set("key1", "value1")

      subject.store.should eq({"key1" => "value1"})
    end
  end

  describe "#save" do
    it "writes file with store" do
      subject.set("key1", "value1")
      subject.set("key2", "value2")
      subject.save

      File.read(subject.path).should eq(%({"key1":"value1","key2":"value2"}))
    end
  end

  describe "#load" do
    let(hash) { { "key1" => "1", "key2" => "2" } }

    before { File.write(subject.path, hash.to_json) }

    it "loads json from file" do
      subject.load

      subject.store["key1"].should eq(hash["key1"])
      subject.store["key2"].should eq(hash["key2"])
    end
  end
end