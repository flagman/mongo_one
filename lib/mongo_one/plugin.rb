module MongoOne
  class Plugin
    attr_reader :klass, :config

    def initialize(klass, config = {})
      @klass = klass # MongoOne::SchemaBuilder
      @config = config
    end

    def apply
      raise NotImplementedError
    end

    def before_create(attributes); end
    def before_update(attributes); end
    def before_delete(attributes); end
    def after_create(attributes); end
    def after_update(attributes); end
    def after_delete(attributes); end
  end
end
