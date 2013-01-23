require 'spec_helper'

describe Thor::Tree do

  let(:yaml_source_path) { Path.dir / '..' / 'fixtures' }
  let(:good_yaml_1) { yaml_source_path / 'example.yml' }
  let(:output) do
    {
      files: {
        'fa0'     => 'file content',
        'fa1'     => '',
        'da1/fb0' => '',
      },
      directories: {
        'da0'           => [],
        'da1'           => ['fb0', 'db0'],
        'da1/db0'       => ['dc0'],
        'da1/db0/dc0'   => [],
      }
    }
  end
  let(:directories) { output[:directories].keys }
  let(:created_files) { ['fa0', 'fa1', 'da1/fb0'] }

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
          created_files.each do |file|
            (Path.dir / '..' / 'sandbox' / file ).should exist
          end
        end

        it "creates files with the specified content" do
          created_files.each do |file|
            File.read(Path.dir / '..' / 'sandbox' / file ).should == output[:files][file]
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
