module MongoOne
  module InstanceMethods
    def find(*)
      self.class.find(*)
    end

    def aggregate(*)
      self.class.aggregate(*)
    end

    def update_one(*)
      self.class.update_one(*)
    end

    def update_many(*)
      self.class.update_many(*)
    end

    def insert_one(*)
      self.class.insert_one(*)
    end

    def insert_many(*)
      self.class.insert_many(*)
    end

    def delete_one(*)
      self.class.delete_one(*)
    end

    def delete_many(*)
      self.class.delete_many(*)
    end

    def collection
      self.class.collection
    end
  end
end
