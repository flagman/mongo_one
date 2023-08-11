module MongoOne
  class Query
    attr_reader :collection, :filter, :aggregation_pipeline, :hint_value, :options
    attr_accessor :projection_enabled, :projection_builders, :update_pipeline

    def initialize(klass)
      @klass = klass
      @collection = klass.collection
      @filter = {}
      @options = {}
      @aggregation_pipeline = nil
      @limit_value = nil
      @hint_value = nil
      @projection_enabled = true
      @projection_builders = {}
      @update_pipeline = nil
    end

    def find(query = {}, options = {})
      filter.merge!(query)
      options.merge!(options)
      self
    end

    def auto_project(value)
      @projection_enabled = value
      self
    end

    def aggregate(_pipeline, options = {})
      options.merge!(options)
      @aggregation_pipeline = pipelene
      self
    end

    def update_one(update_filter, document_or_pipeline, update_options = {})
      options.merge!(update_options)
      update(update_filter, document_or_pipeline, :update_one)
    end

    def update_many(update_filter, document_or_pipeline, update_options = {})
      options.merge!(update_options)
      update(update_filter, document_or_pipeline, :update_many)
    end

    def insert_one(doc)
      insert(doc, :insert_one)
    end

    def insert_many(docs)
      insert(docs, :insert_many)
    end

    def insert(doc_or_docs, insert_method)
      @klass.plugins.each { |plugin| plugin.before_create(doc_or_docs) }
      collection.send(insert_method, doc_or_docs)
      @klass.plugins.each { |plugin| plugin.after_create(doc_or_docs) }
    end

    def delete_many(query = {})
      collection.delete_many(query)
    end

    def delete_one(query = {})
      collection.delete_one(query)
    end

    def count
      collection.count(filter)
    end

    def hint(index_name)
      options[:hint] = index_name.to_s
      self
    end

    def sort(sort_options)
      options[:sort] = sort_options
      self
    end

    def limit(value)
      options[:limit] = value
      self
    end

    def auto_map
      map_to(@klass::Struct)
    end

    def map_to(klass)
      apply_projection_if_exists(klass)
      result = execute_query
      map_documents_to_class(result, klass)
    end

    private

    def apply_projection_if_exists(klass)
      return unless projection_enabled

      projection_builder = projection_builders[klass] ||= ProjectionBuilder.new(klass)

      projection_builder = ProjectionBuilder.new(klass) if MongoOne.testing?
      options[:projection] = projection_builder.fields
    end

    def update(update_filter, document_or_pipeline, update_method)
      @klass.plugins.each { |plugin| plugin.before_update(document_or_pipeline) }
      collection.send(update_method, update_filter, document_or_pipeline, options)
      @klass.plugins.each { |plugin| plugin.after_update(document_or_pipeline) }
    end

    def execute_query
      return collection.aggregate(aggregation_pipeline, options) if aggregation_pipeline

      collection.find(filter, options)
    end

    def map_documents_to_class(result, klass)
      result.map { |doc| klass.new(doc) }
    end
  end
end
