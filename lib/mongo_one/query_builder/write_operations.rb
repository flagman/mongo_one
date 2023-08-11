module MongoOne
  module QueryBuilder
    module WriteOperations
      def insert_one(doc)
        insert(doc, :insert_one)
      end

      def insert_many(docs)
        insert(docs, :insert_many)
      end

      def update_one(update_filter, document_or_pipeline, update_options = {})
        options.merge!(update_options)
        update(update_filter, document_or_pipeline, :update_one)
      end

      def update_many(update_filter, document_or_pipeline, update_options = {})
        options.merge!(update_options)
        update(update_filter, document_or_pipeline, :update_many)
      end

      private

      def insert(doc_or_docs, insert_method)
        @klass.plugins.each { |plugin| plugin.before_create(doc_or_docs) }
        collection.send(insert_method, doc_or_docs)
        @klass.plugins.each { |plugin| plugin.after_create(doc_or_docs) }
      end

      def update(update_filter, document_or_pipeline, update_method)
        @klass.plugins.each { |plugin| plugin.before_update(document_or_pipeline) }
        collection.send(update_method, update_filter, document_or_pipeline, options)
        @klass.plugins.each { |plugin| plugin.after_update(document_or_pipeline) }
      end
    end
  end
end
