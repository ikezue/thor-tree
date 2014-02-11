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
        @_path = Path.new args[0].to_s
        @_filename = @_path.basename
        options.merge! options_from_args(args[1])
        super
        self.destination_root = Writer.root_path
        File.template_variables.each { |key, value| instance_variable_set key, value }
      end

      no_tasks do
        def write
          case options[:action]
          when :copy_file
            copy_file options[:source] || @_filename, @_path, options[:thor_opts]
          when :create_file
            create_file @_path, options[:content].to_s, options[:thor_opts]
          when :template
            template options[:source] || @_filename, @_path, options[:thor_opts]
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
              h = args.map { |k, v| [k[1..-1].to_sym, v] }.to_h
              opts[:action]  = actions.find { |action| action == h.keys.first } || :create_file
              opts[:content] = h.delete :create_file
              opts[:source]  = h.delete(:copy_file) || h.delete(:template)
              opts[:thor_opts] = h
            end
          end
        end
      end
    end
  end
end
