require 'core_ext/hash'
require 'thor/tree/version'

class Thor
  require 'yaml'

  class Tree
    def initialize(file)
      @options = YAML.load_file(File.expand_path(file)).symbolize_keys!
    end

    def options
      @options ||= {}
    end
  end
end
