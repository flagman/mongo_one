module MongoOne
  class SchemaBuilder
    attr_accessor :attributes
    attr_reader :klass
    alias extended_class klass # for plugins

    def initialize(klass, parent_builder = nil)
      @klass = klass
      @attributes = {}
      @indexes = []
      @plugins = {}
      @parent_builder = parent_builder
      return unless parent_builder.nil?

      attribute(:_id, Types::Any)
    end

    def attribute?(name, type, &block)
      attribute("#{name}?".to_sym, type, &block)
    end

    def attribute(name, type, &block)
      if block
        nested_builder = self.class.new(@klass, self)
        nested_builder.instance_eval(&block)
        nested_attributes = nested_builder.attributes.transform_values { |v| v[:type] }
        @attributes[name] = if type == Types::Array
                              { type: Types::Array.of(Types::Hash.schema(nested_attributes).with_key_transform(&:to_sym)) }
                            else
                              { type: Types::Hash.schema(nested_attributes).with_key_transform(&:to_sym) }
                            end
      else
        @attributes[name] = { type: }
      end
    end

    def indexes(&block)
      @indexes = IndexBuilder.new(self).instance_eval(&block)
      extended_class.indexes = @indexes
    end

    def plugins(&block)
      PluginsBuilder.new(self).instance_eval(&block)
    end

    def instance_eval(&block)
      super
      apply_schema if @parent_builder.nil?
    end

    private

    def define_struct_class
      attrs = @attributes # to avoid closure
      klass = Class.new(Dry::Struct) do
        transform_keys(&:to_sym)
        attrs.each do |name, details|
          attribute name, details[:type]
        end
      end

      @klass.const_set(:Struct, klass)
    end

    def apply_schema
      @klass.attributes = @attributes
      define_struct_class
    end
  end
end
