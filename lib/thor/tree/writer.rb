class Thor
  class Tree
    class Writer < Thor
      include Thor::Actions

      class << self
        # Destination root for class
        def root_path=(path); @_destination_root = path; end
        def root_path; @_destination_root; end
      end

      def initialize(args=[], options={}, config={})
        super
        Writer.root_path = Path(destination_root).expand
      end

      no_tasks do
        def write(contents)
          return unless contents.is_a?(Hash)

          Tree::Directory.new([Writer.root_path]).tap do |root|
            contents.each do |content_path, options|
              root.add content_path, options
            end
          end.write
        end
      end
    end
  end
end
