require 'spec_helper'
require 'thor/tree'

describe Thor::Tree do
  describe "#set_template_variable" do
    let(:tmp_dir) { Path.tmpdir }
    let(:src) { tmp_dir / 'src' }
    let(:dst) { tmp_dir / 'dst' }
    let(:tree_yaml) { tmp_dir / 'tree.yml' }
    let(:ivar_value) { 'some value' }

    before do
      File.open src, 'w' do |f|
        f.write "<%= @ivar %>\n"
      end

      File.open tree_yaml, 'w' do |f|
        f.write "destination_root: #{tmp_dir}\n"
        f.write "source_paths:\n"
        f.write "- #{tmp_dir}\n"
        f.write "content:\n"
        f.write "  dst: { ':template': 'src' }\n"
      end

      tree_writer = Thor::Tree.new(tree_yaml)
      tree_writer.set_template_variable '@ivar', ivar_value
      tree_writer.write
    end

    after do
      tmp_dir.rm_rf
    end

    it "sets a value for an ERB variable" do
      expect(File.read dst).to match(ivar_value)
    end
  end

  describe "#write" do
    describe "file creation" do
      context "with :create_file" do
        let(:tmp_dir) { Path.tmpdir }
        let(:file1) { tmp_dir / 'file1' }
        let(:file2) { tmp_dir / 'file2' }
        let(:tree_yaml) { tmp_dir / 'tree.yml' }
        let(:file2_content) { 'some_content' }

        before do
          File.open tree_yaml, 'w' do |f|
            f.write "destination_root: #{tmp_dir}\n"
            f.write "content:\n"
            f.write "  file1: ':create_file'\n"
            f.write "  file2: { ':create_file': #{file2_content} }\n"
          end

          Thor::Tree.new(tree_yaml).write
        end

        after do
          tmp_dir.rm_rf
        end

        it "creates the named file" do
          expect(file1).to exist
        end

        it "creates files with the specified content" do
          expect(File.read file2).to eq(file2_content)
        end
      end

      context "with :copy_file" do
        let(:tmp_dir) { Path.tmpdir }
        let(:src) { tmp_dir / 'src' }
        let(:dst) { tmp_dir / 'dst' }
        let(:tree_yaml) { tmp_dir / 'tree.yml' }
        let(:src_content) { 'some content' }

        before do
          File.open src, 'w' do |f|
            f.write src_content
          end

          File.open tree_yaml, 'w' do |f|
            f.write "destination_root: #{tmp_dir}\n"
            f.write "source_paths:\n"
            f.write "- #{tmp_dir}\n"
            f.write "content:\n"
            f.write "  dst: { ':copy_file': 'src' }\n"
          end

          Thor::Tree.new(tree_yaml).write
        end

        after do
          tmp_dir.rm_rf
        end

        it "creates a copy of the source file" do
          expect(File.read dst).to eq(src_content)
        end
      end

      context "with :template" do
        let(:tmp_dir) { Path.tmpdir }
        let(:src) { tmp_dir / 'src' }
        let(:dst) { tmp_dir / 'dst' }
        let(:tree_yaml) { tmp_dir / 'tree.yml' }
        let(:src_content) { 'some content with a <%= @variable %>' }
        let(:variable_value) { 'some value' }

        before do
          File.open src, 'w' do |f|
            f.write src_content
          end

          File.open tree_yaml, 'w' do |f|
            f.write "destination_root: #{tmp_dir}\n"
            f.write "source_paths:\n"
            f.write "- #{tmp_dir}\n"
            f.write "content:\n"
            f.write "  dst: { ':template': 'src' }\n"
          end

          tree_writer = Thor::Tree.new(tree_yaml)
          tree_writer.set_template_variable '@variable', variable_value
          tree_writer.write
        end

        after do
          tmp_dir.rm_rf
        end

        it "creates a copy of the source file with interpolated source content" do
          expect(File.read dst).to eq(src_content.gsub(/<%=.*%>/, variable_value))
        end
      end
    end

    describe "directory creation" do
      let(:tmp_dir) { Path.tmpdir }
      let(:tree_yaml) { tmp_dir / 'tree.yml' }

      before do
        File.open tree_yaml, 'w' do |f|
          f.write "destination_root: #{tmp_dir}\n"
          f.write "content:\n"
          f.write "  dir_1:\n"
          f.write "    dir_11:\n"
          f.write "      file_111: ':create_file'\n"
          f.write "    dir_12:\n"
          f.write "      dir_121: {}\n"
        end

        Thor::Tree.new(tree_yaml).write
      end

      after do
        tmp_dir.rm_rf
      end

      it "creates the directory tree" do
        root = tmp_dir / 'dir_1'
        expect(root).to exist
        expect(root.children).to eq([root/'dir_11', root/'dir_12'])
        expect((root/'dir_11').children).to eq([root/'dir_11'/'file_111'])
        expect((root/'dir_12').children).to eq([root/'dir_12'/'dir_121'])
        expect(root / 'dir_12' / 'dir_121').to be_a_directory
        expect(root / 'dir_11' / 'file_111').to be_a_file
      end
    end
  end

  context "example.yml" do
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

    before do
      (Path.dir / '..' / 'sandbox').rm_rf

      template_variables = Hash.new.tap do |h|
        h['@fa4_content'] = 'fa4 content'
        h['@fa5_content'] = 'fa5 content'
        h['@fb2_content'] = 'fb2 content'
        h['@fc1_content'] = 'fc1 content'
      end

      example_yaml = Path.dir / '..' / 'fixtures' / 'example.yml'

      Thor::Tree.new(example_yaml).tap do |tree|
        template_variables.each do |key, value|
          tree.set_template_variable key, value
        end
      end.write
    end

    it "creates the tree" do
      files_to_create.each do |file|
        (Path.dir / '..' / 'sandbox' / file).should exist
      end

      files_to_create.each do |file|
        File.read(Path.dir / '..' / 'sandbox' / file).strip.should == output[:files_to_create][file]
      end

      files_to_copy.each do |file|
        File.read(Path.dir / '..' / 'sandbox' / file).strip.should == output[:files_to_copy][file]
      end

      files_to_template.each do |file|
        File.read(Path.dir / '..' / 'sandbox' / file).strip.should == output[:files_to_template][file]
      end

      directories.each do |dir|
        (Path.dir / '..' / 'sandbox' / dir).should exist
      end

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
