require 'spec_helper'

describe Thor::Tree do

  let(:tree) { Thor::Tree.new 'good_yaml_good_tree' }

  describe "#destination_root" do
    it "is set to the current directory by default" do
      tree.destination_root.should == File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end

    it "returns a previously defined root" do
      tree.destination_root = destination_root
      tree.destination_root.should == destination_root
    end
  end

  describe "#destination_root=" do
    context "with an absolute path" do
      it "sets root to the given path" do
        tree.destination_root = destination_root
        tree.destination_root.should == destination_root
      end
    end

    context "with a relative path" do
      it "sets root to an absolute path using the current directory as base" do
        'root'.tap do |r|
          tree.destination_root = r
          tree.destination_root.should == File.expand_path(File.join(File.dirname(__FILE__), '..', '..', r))
        end
      end
    end
  end

  describe "#source_paths" do
    it "returns an array" do
      tree.source_paths.class.should == Array
    end

    it "holds a list of source paths" do
      tree.source_paths << source_root
      tree.source_paths.should include(source_root)
    end
  end

  describe ".new" do
  end
end