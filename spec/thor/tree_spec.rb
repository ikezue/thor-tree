require 'spec_helper'

describe Thor::Tree do

  let(:yaml_source_path) { Path.dir / '..' / 'fixtures' }
  let(:good_yaml_1) { yaml_source_path / 'good_example_1.yml' }

  describe ".new" do
    context "with a properly-formatted YAML file" do
      it "loads the YAML file" do
        Thor::Tree.new(good_yaml_1).options.class.should == Hash
      end
    end

    context "with a wrongly-formatted YAML file" do
      it "raises a YAML error"
    end
  end

  describe "#write" do
    before do
      ::FileUtils.rm_rf(destination_root)
    end

    let(:tree) { Thor::Tree.new(good_yaml_1) }

    it "writes files to the specified destination root" do
      tree.write
      File.exists?(Path.dir / '..' / 'sandbox' / 'file').should be_true

      # expect {
      #   tree.write
      # }.to change {
      #   File.exist? File.expand_path File.join(File.dirname(__FILE__), '..', 'sandbox', 'file')
      # }.from(false).to(true)
    end

    it "writes directories to the specified destination root" do
      tree.write
      File.exists?(Path.dir / '..' / 'sandbox' / 'dir').should be_true

      # expect {
      #   tree.write
      # }.to change {
      #   File.exist? File.expand_path File.join(File.dirname(__FILE__), '..', 'sandbox', 'dir')
      # }.from(false).to(true)
    end
  end
end
