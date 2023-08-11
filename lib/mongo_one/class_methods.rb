module MongoOne
  module ClassMethods
    attr_accessor :attributes, :collection_name, :indexes

    def schema(name, &block)
      @collection_name = name.to_s
      SchemaBuilder.new(self).instance_eval(&block)
    end

    def find(*)
      QueryBuilder::Query.new(self).find(*)
    end

    def aggregate(*)
      QueryBuilder::Query.new(self).aggregate(*)
    end

    def update_one(*)
      QueryBuilder::Query.new(self).update_one(*)
    end

    def update_many(*)
      QueryBuilder::Query.new(self).update_many(*)
    end

    def insert_one(*)
      QueryBuilder::Query.new(self).insert_one(*)
    end

    def insert_many(*)
      QueryBuilder::Query.new(self).insert_many(*)
    end

    def delete_one(*)
      QueryBuilder::Query.new(self).delete_one(*)
    end

    def delete_many(*)
      QueryBuilder::Query.new(self).delete_many(*)
    end

    def collection
      MongoOne.client[collection_name]
    end

    def plugins
      @plugins ||= []
    end

    def indexes
      @indexes ||= []
    end
  end
end
