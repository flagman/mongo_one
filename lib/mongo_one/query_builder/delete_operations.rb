module MongoOne
  module QueryBuilder
    module DeleteOperations
      def delete_one(query = {})
        collection.delete_one(query)
      end

      def delete_many(query = {})
        collection.delete_many(query)
      end
    end
  end
end
