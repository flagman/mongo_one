module MongoOne
  class AutoIndex
    class << self
      def apply_indexes
        MongoOne.included_in.each do |klass|
          ensure_collection_exists(klass)
          process_class_indexes(klass)
        end
      end

      def fetch_existing_indexes(klass)
        klass.collection.indexes.to_a.reject { |idx_info| idx_info["name"] == '_id_' }.map { |idx_info| idx_info.except('v') }
      end

      private

      def process_class_indexes(klass)
        existing_indexes = fetch_existing_indexes(klass)
        defined_indexes = fetch_defined_indexes(klass)

        drop_undefined_indexes(klass, existing_indexes, defined_indexes)
        create_missing_indexes(klass, existing_indexes, defined_indexes)
      end

      def ensure_collection_exists(klass)
        db = klass.collection.database
        existing_collections = db.collections.map { |c| c.namespace.sub("#{db.name}.", '') }
        collection_name = klass.collection.name
        return if existing_collections.include?(collection_name)

        klass.collection.create
      end

      def fetch_defined_indexes(klass)
        klass.indexes
      end

      def drop_undefined_indexes(klass, existing_indexes, defined_indexes)
        indexes_to_drop = existing_indexes - defined_indexes
        indexes_to_drop.map { |i| i["name"] }.each do |index_name|
          klass.collection.indexes.drop_one(index_name)
        end
      end

      def create_missing_indexes(klass, existing_indexes, _defined_indexes)
        klass.indexes.each do |index_def|
          index_name = index_def["name"]
          next if existing_indexes.include?(index_name) || index_name == '_id_'

          keys = index_def["key"]
          options = index_def.except { |k, _| k == "key" }
          klass.collection.indexes.create_one(keys, options.merge(name: index_name.to_s))
        end
      end
    end
  end
end
