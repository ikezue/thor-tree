require 'spec_helper'

describe Thor::Tree do

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
      files_to_template: {
        'fa4'         => 'fa4 content',
        'fa5'         => 'fa5 content',
        'da1/fb2'     => 'fb2 content',
        'da1/db0/fc1' => 'fc1 content',
      },
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

  describe "#write" do
    before :all do
      example_yaml = Path.dir / '..' / 'fixtures' / 'example.yml'
      template_variables = Hash.new.tap do |h|
        h['@fa4_content'] = 'fa4 content'
        h['@fa5_content'] = 'fa5 content'
        h['@fb2_content'] = 'fb2 content'
        h['@fc1_content'] = 'fc1 content'
      end

      ::FileUtils.rm_rf(destination_root)
      Thor::Tree.new(example_yaml).tap do |tree|
        template_variables.each do |key, value|
          tree.set_template_variable key, value
        end
      end.write
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

      context "with :template" do
        it "creates files with interpolated source content" do
          files_to_template.each do |file|
            File.read(Path.dir / '..' / 'sandbox' / file ).strip.should == output[:files_to_template][file]
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
