class Thor
  class Tree
    class File < Thor
      include Thor::Actions

      class << self
        def ===(args)
          args.is_a?(String) || args.is_a?(Hash) && args.keys.first.start_with?(':')
        end
      end

      def initialize(args, options = {}, config = {})
        @path = Path.new args[0].to_s
        @filename = @path.basename
        options.merge! options_from_args(args[1])
        super
        self.destination_root = Writer.root_path
      end

      def write
        case options[:action]
        when :copy_file
          copy_file options[:source] || @filename, @path
        when :create_file
          create_file @path, options[:content].to_s
        when :template
          template options[:source] || @filename, @path
        end
      end

      private

      def options_from_args(args)
        Hash.new.tap do |opts|
          [:copy_file, :create_file, :template].tap do |actions|
            case args
            when String
              opts[:action]  = actions.find { |action| action == args[1..-1].to_sym } || :create_file
            when Hash
              opts[:action]  = actions.find { |action| action == args.keys.first[1..-1].to_sym } || :create_file
              opts[:content] = args[':create_file']
              opts[:source]  = args[':copy_file'] || args[':template']
            end
          end
        end
      end
    end

    class Directory < Thor
      include Thor::Actions

      class << self
        def ===(args)
          args.is_a?(Hash) && args.keys.all? { |key| key.start_with?(':') == false }
        end
      end

      def initialize(args, options = {}, config = {})
        @path = Path.new args.first.to_s
        super
        self.destination_root = Writer.root_path
      end

      def add(path, args)
        case args
        when File
          add_file path, args
        when Directory
          add_subdirectory path, args
        end
      end

      desc 'write', 'writes this ThorFolder and all its subfolders and files to disk'
      def write
        empty_directory @path
        subdirectories.each { |dir| dir.write }
        files.each { |file| file.write }
      end

      private

      def add_file(file_path, options)
        files << File.new([@path / file_path, options])
      end

      def add_subdirectory(dir_path, contents)
        path = @path / dir_path

        subdirectories.find { |dir| dir.path == path } || Tree::Directory.new([path]).tap do |dir|
          subdirectories << dir
        end.tap do |dir|
          contents.each do |content_path, options|
            dir.add content_path, options
          end
        end
      end

      def files; @files ||= []; end
      def subdirectories; @subdirectories ||= []; end
    end

    class Writer < Thor
      include Thor::Actions

      class << self
        # Destination root for class
        def root_path=(path); @_destination_root = path; end
        def root_path; @_destination_root; end

        # Stores variables to be used by instances of this class in templates.
        #
        # @param key [Symbol]         instance variable to set
        # @param value [String]       value to substitute in template
        # @examples
        #   Thor::Tree::Writer.set_template_variable :@title, 'Mr.'
        def set_template_variable(key, value)
          @_template_variables ||= {}
          @_template_variables[key] = value
        end

        # Returns the hash of stored template variables
        def template_variables
          @_template_variables || {}
        end

      end

      def initialize(args=[], options={}, config={})
        super
        Writer.root_path = Path(destination_root).expand
      end

      def write(contents)
        return unless contents.is_a?(Hash)
        $stdout.puts contents

        Tree::Directory.new([Writer.root_path]).tap do |root|
          contents.each do |content_path, options|
            root.add content_path, options
          end
        end.write
      end
    end
  end
end