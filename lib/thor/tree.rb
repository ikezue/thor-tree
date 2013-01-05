require 'thor/tree/version'

class Thor
  class Tree
    def initialize(file)
    end

    def source_paths
      @source_paths ||= []
    end

    def destination_root
      @destination_root || File.expand_path('.')
    end

    def destination_root=(root)
      @destination_root = File.expand_path root
    end
  end
end
