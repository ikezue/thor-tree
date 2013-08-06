require 'safe_yaml'
require 'core_ext/hash'
require 'path'
require 'thor'
require 'thor/actions'
require 'thor/tree/directory'
require 'thor/tree/file'
require 'thor/tree/version'
require 'thor/tree/writer'

class Thor
  class Tree
    def initialize(file)
      @options = YAML.load_file(Path(file).expand, safe: true).symbolize_keys!
    end

    def set_template_variable(key, value)
      Tree::File.set_template_variable key, value
    end

    def write
      source_paths.each do |path|
        Tree::File.source_paths << path
      end

      Tree::Writer.new([], {}, destination_root: options[:destination_root]).tap do |w|
        w.write options[:content]
      end
    end

    private

    def options
      @options ||= {}
    end

    def source_paths
      options[:source_paths] ||= []
    end
  end
end
