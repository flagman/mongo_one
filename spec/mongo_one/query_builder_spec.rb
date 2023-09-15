RSpec.describe "MongoOne::QueryBuilder" do
  before do
    MongoOne::Db.configure(database: 'test_db', addr: 'localhost')
    MongoOne::Db.establish_connection

    MongoOne.client[:test_users].drop
  end

  after do
    MongoOne::Db.close_connection
  end

  let(:user_collection) do
    Class.new do
      include MongoOne
      extend MongoOne::ClassMethods

      schema :test_users do
        attribute :name, Types::String
        attribute :age, Types::Integer
      end
    end
  end

  describe "#find" do
    it "finds documents based on a given query" do
      user_collection.insert_one(name: 'Alice', age: 25)
      user = user_collection.find(name: 'Alice').limit(1).one
      expect(user.name).to eq('Alice')
    end

    it "raises an error if no document is found" do
      user_collection.insert_one(name: 'Alice', age: 25)
      expect { user_collection.find(name: 'Bob').one! }.to raise_error(MongoOne::Errors::NotFoundError)
    end

    context "when skip is used" do
      it "skips the given number of documents" do
        user_collection.insert_one(name: 'Alice', age: 25)
        user_collection.insert_one(name: 'Bob', age: 30)
        user_collection.insert_one(name: 'Charlie', age: 35)
        users = user_collection.find.skip(1).all
        expect(users.count).to eq(2)
      end
    end
  end

  describe "#aggregate" do
    let(:aggregation_struct) do
      Class.new(Dry::Struct) do
        transform_keys(&:to_sym)
        attribute :_id, Types::Integer
        attribute :count, Types::Integer
      end
    end

    it "aggregates documents based on a given pipeline" do
      user_collection.insert_many([{ name: 'Alice', age: 25 }, { name: 'Bob', age: 30 }, { name: 'Charlie', age: 25 }])

      pipeline = [
        { '$group' => { '_id' => '$age', 'count' => { '$sum' => 1 } } }
      ]

      result = user_collection.aggregate(pipeline).map_to(aggregation_struct).all

      aggregated = result.find { |res| res._id == 25 }

      expect(aggregated.count).to eq(2)
    end
  end

  describe "#update_one" do
    it "updates a single document based on a given query" do
      user_collection.insert_one(name: 'Alice', age: 25)

      user_collection.update_one({ name: 'Alice' }, { "$set" => { age: 26 } })
      user = user_collection.find(name: 'Alice').limit(1).one

      expect(user.age).to eq(26)
    end
  end

  describe "#update_many" do
    it "updates multiple documents based on a given query" do
      user_collection.insert_many([{ name: 'Alice', age: 25 }, { name: 'Bob', age: 25 }])

      user_collection.update_many({ age: 25 }, { "$set" => { age: 26 } })
      users = user_collection.find(age: 26).all

      expect(users.count).to eq(2)
    end
  end

  describe "#insert_one" do
    it "inserts a single document" do
      user_collection.insert_one(name: 'Bob', age: 30)

      user = user_collection.find(name: 'Bob').limit(1).one!
      expect(user.name).to eq('Bob')
    end
  end

  describe "#insert_many" do
    it "inserts multiple documents" do
      users_to_insert = [{ name: 'Alice', age: 25 }, { name: 'Bob', age: 30 }]
      user_collection.insert_many(users_to_insert)

      users = user_collection.find.all
      expect(users.count).to eq(2)
    end
  end

  describe "#delete_one" do
    it "deletes a single document based on a given query" do
      user_collection.insert_one(name: 'Charlie', age: 40)
      user_collection.delete_one(name: 'Charlie')
      users = user_collection.find(name: 'Charlie').all

      expect(users.count).to eq(0)
    end
  end

  describe "#delete_many" do
    it "deletes multiple documents based on a given query" do
      user_collection.insert_many([{ name: 'Dave', age: 35 }, { name: 'Eve', age: 35 }])

      user_collection.delete_many(age: 35)
      users = user_collection.find(age: 35).all

      expect(users.count).to eq(0)
    end
  end
end
