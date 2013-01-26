require 'spec_helper'

# See the following links for help with YAML:
# http://www.yaml.org/YAML_for_ruby.html
# http://yaml-online-parser.appspot.com/

describe Thor::Tree do

  let(:yaml_source_path) { Path.dir / '..' / 'fixtures' }
  let(:good_yaml_1) { yaml_source_path / 'example.yml' }
  let(:output) do
    {
      files_to_create: {
        'fa0'         => 'fa0 content',
        'fa1'         => '',
        'da1/fb0'     => '',
      },
      files_to_copy: {
        'fa2'         => 'fa2 content',
        'fa3'         => 'fa3 content',
        'da1/fb1'     => 'fb1 content',
        'da1/db0/fc0' => 'fc0 content',
      },
      files_to_template: {},
      directories: {
        'da0'           => [],
        'da1'           => ['fb0', 'db0'],
        'da1/db0'       => ['dc0'],
        'da1/db0/dc0'   => [],
      }
    }
  end

  let(:directories)       { output[:directories].keys }
  let(:files_to_create)   { output[:files_to_create].keys }
  let(:files_to_copy)     { output[:files_to_copy].keys }
  let(:files_to_template) { output[:files_to_template].keys }

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
    before :all do
      ::FileUtils.rm_rf(destination_root)
      Thor::Tree.new(good_yaml_1).write
    end

    describe "file creation" do
      context "with :create_file" do
        it "creates the named file" do
          files_to_create.each do |file|
            (Path.dir / '..' / 'sandbox' / file ).should exist
          end
        end

        it "creates files with the specified content" do
          files_to_create.each do |file|
            File.read(Path.dir / '..' / 'sandbox' / file ).strip.should == output[:files_to_create][file]
          end
        end
      end

      context "with :copy_file" do
        it "creates files with source content" do
          files_to_copy.each do |file|
            File.read(Path.dir / '..' / 'sandbox' / file ).strip.should == output[:files_to_copy][file]
          end
        end
      end
    end

    describe "directory creation" do
      it "creates the named directory" do
        directories.each do |dir|
          (Path.dir / '..' / 'sandbox' / dir).should exist
        end
      end

      it "creates directories with the specified content" do
        directories.each do |dir|
          (Path.dir / '..' / 'sandbox' / dir).children(false).map { |c| c.to_s }.tap do |subdirs|
            output[:directories][dir].each do |sub|
              subdirs.should include sub
            end
          end
        end
      end
    end
  end
end
