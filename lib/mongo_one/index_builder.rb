module MongoOne
  class IndexBuilder
    attr_reader :klass, :indexes

    def initialize(klass)
      @klass = klass
      @indexes = []
    end

    def index(name, keys:, options: {})
      # make index compatible with mongo indexes info
      @indexes << { "key" => keys.transform_keys(&:to_s), "name" => name.to_s }.merge(options.transform_keys(&:to_s))
    end
  end
end
