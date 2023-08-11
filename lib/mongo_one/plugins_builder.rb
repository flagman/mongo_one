module MongoOne
  class PluginsBuilder
    def initialize(klass)
      @klass = klass
    end

    def use(plugin_class, config = {})
      plugin = plugin_class.new(@klass, config)
      plugin.apply
      @klass.extended_class.plugins << plugin
    end
  end
end
