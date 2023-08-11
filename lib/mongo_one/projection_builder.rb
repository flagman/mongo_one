module MongoOne
  class ProjectionBuilder
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def fields
      @fields ||= extract_fields(klass)
    end

    private

    def extract_fields(klass)
      parser = MongoOne::Ast::Parser.new
      meta = parser.visit(klass.schema.to_ast)
      map_meta_to_projection(meta)
    end

    def map_meta_to_projection(meta)
      output = {}

      meta.each do |element|
        if element.is_a?(Hash)
          output[element[:key].to_s] = 1
        elsif element.is_a?(Array)
          output.merge!(map_meta_to_projection(element))
        end
      end
      output
    end
  end
end
