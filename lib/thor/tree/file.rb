class Thor
  class Tree
    class File < Thor
      include Thor::Actions

      class << self
        def ===(args)
          args.is_a?(String) ||
          args.is_a?(Hash) && !args.empty? && args.keys.first.start_with?(':')
        end

        def set_template_variable(key, value)
          @_template_variables ||= {}
          @_template_variables[key] = value
        end

        def template_variables
          @_template_variables || {}
        end
      end

      # @examples
      #   File.new [ 'path/to/dst', ':create_file' ]
      #   File.new [ 'path/to/dst', { ':create_file' => 'file content' } ]
      #   File.new [ 'path/to/dst', ':copy_file' ]
      #   File.new [ 'path/to/dst', { ':copy_file' => 'source_file' } ]
      #   File.new [ 'path/to/dst', ':template' ]
      #   File.new [ 'path/to/dst', { ':template' => 'source_file' } ]
      def initialize(args, options = {}, config = {})
        # $stdout.puts args
        @path = Path.new args[0].to_s
        @filename = @path.basename
        options.merge! options_from_args(args[1])
        super
        self.destination_root = Writer.root_path
        File.template_variables.each { |key, value| instance_variable_set key, value }
      end

      no_tasks do
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
  end
end
