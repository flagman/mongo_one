module MongoOne
  module QueryBuilder
    module ReadOperations
      attr_accessor :aggregation_pipeline, :projection_disabled, :map_class

      def find(query = {}, options = {})
        filter.merge!(query)
        self.options.merge!(options)
        self
      end

      def count
        collection.count(filter)
      end

      def sort(sort_options)
        options[:sort] = sort_options
        self
      end

      def auto_project(value)
        self.projection_disabled = !value
        self
      end

      def map_to(klass)
        apply_projection_if_enabled(klass)
        self.map_class = klass
        self
      end

      def one!
        one.tap do |result|
          raise Errors::NotFoundError, "Document not found" if result.nil?
        end
      end

      def one
        result = mongo_query.first
        return nil if result.nil?

        _map_class.new(result)
      end

      def all
        mongo_query.map { |doc| _map_class.new(doc) }
      end

      def aggregate(pipeline, options = {})
        options.merge!(options)
        self.aggregation_pipeline = pipeline
        self
      end

      def mongo_query
        return collection.aggregate(aggregation_pipeline, options) if aggregation_pipeline

        collection.find(filter, options)
      end

      def projection_builders
        @projection_builders ||= {}
      end

      private

      def _map_class
        map_class || @klass::Struct
      end

      def apply_projection_if_enabled(klass)
        return if projection_disabled

        projection_builder = projection_builders[klass] ||= ProjectionBuilder.new(klass)

        projection_builder = ProjectionBuilder.new(klass) if MongoOne.testing?
        options[:projection] = projection_builder.fields
      end
    end
  end
end
