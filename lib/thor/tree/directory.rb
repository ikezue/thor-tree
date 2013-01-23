class Thor
  class Tree
    class Directory < Thor
      include Thor::Actions

      attr_reader :path

      class << self
        def ===(args)
          args.is_a?(Hash) &&
          (args.empty? || args.keys.all? { |key| key.start_with?(':') == false })
        end
      end

      def initialize(args, options = {}, config = {})
        @path = Path.new args.first.to_s
        super
        self.destination_root = Writer.root_path
      end

      no_tasks do
        def add(path, args)
          case args
          when File
            add_file path, args
          when Directory
            add_subdirectory path, args
          end
        end

        def write
          empty_directory @path
          subdirectories.each { |dir| dir.write }
          files.each { |file| file.write }
        end
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
  end
end
