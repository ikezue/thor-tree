require 'spec_helper'

describe Thor::Tree do

  let(:yaml_source_path) { File.join(File.dirname(__FILE__), '..', 'fixtures') }
  let(:good_yaml_1) { File.expand_path 'good_example_1.yml', yaml_source_path }

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
end
