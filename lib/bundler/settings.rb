module Bundler
  class Settings
    def initialize(root)
      @root   = root
      @config = File.exist?(config_file) ? YAML.load_file(config_file) : {}
    end

    def [](key)
      key = key_for(key)
      @config[key] || ENV[key]
    end

    def []=(key, value)
      key = key_for(key)
      unless @config[key] == value
        @config[key] = value
        FileUtils.mkdir_p(config_file.dirname)
        File.open(config_file, 'w') do |f|
          f.puts @config.to_yaml
        end
      end
      value
    end

    def without=(array)
      unless array.empty? && without.empty?
        self[:without] = array.join(":")
      end
    end

    def without
      self[:without] ? self[:without].split(":").map { |w| w.to_sym } : []
    end

    def path
      path = ENV[key_for(:path)]

      return path if path

      if path = self[:path]
        "#{path}/#{Gem.ruby_engine}/#{Gem::ConfigMap[:ruby_version]}"
      else
        Gem.dir
      end
    end

  private

    def key_for(key)
      "BUNDLE_#{key.to_s.upcase}"
    end

    def config_file
      Pathname.new("#{@root}/.bundle/config")
    end
  end
end