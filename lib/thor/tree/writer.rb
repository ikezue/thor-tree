class Thor
  class Tree
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

      no_tasks do
        def write(contents)
          return unless contents.is_a?(Hash)
          # p contents

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
