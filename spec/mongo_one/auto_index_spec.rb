RSpec.describe MongoOne::AutoIndex do
  before do
    MongoOne::Db.configure(database: 'test_db', addr: 'localhost')
    MongoOne::Db.establish_connection
    MongoOne.client[:auto].drop
    # Set up test database connection, create necessary collections, etc.
  end

  after do
    MongoOne::Db.close_connection
  end

  context "when there is no indexes in database" do
    let(:autoindexed_class) do
      Class.new do
        include MongoOne
        schema :auto do
          attribute :age, Types::Integer
          attribute :height, Types::Integer
          indexes do
            index :age_height, keys: { age: -1, height: 1 }, options: { sparse: true }
          end
        end
      end
    end

    before do
      autoindexed_class # load class
    end

    it "creates indexes" do
      described_class.apply_indexes
      index_info = described_class.fetch_existing_indexes(autoindexed_class)
      expect(index_info.map { |i| i["name"] }).to include('age_height')
    end
  end

  context "when there is indexes in database" do
    let(:class_v1) do
      Class.new do
        include MongoOne
        schema :auto do
          attribute :age, Types::Integer
          attribute :height, Types::Integer
          indexes do
            index :age_height, keys: { age: -1, height: 1 }, options: { sparse: true }
          end
        end
      end
    end
    let(:class_v2) do
      Class.new do
        include MongoOne
        schema :auto do
          attribute :age, Types::Integer
          indexes do
            index :age, keys: { age: -1 }, options: { sparse: true }
          end
        end
      end
    end

    let(:class_v3) do
      Class.new do
        include MongoOne
        schema :auto do
          attribute :age, Types::Integer
          indexes do
            index :age, keys: { age: 1 }, options: { unique: true }
          end
        end
      end
    end

    it "drops old indexes and creates new ones" do
      class_v1 # load class
      described_class.apply_indexes
      index_info = described_class.fetch_existing_indexes(class_v1)
      expect(index_info.map { |i| i["name"] }).to include('age_height')
      class_v2 # load class
      described_class.apply_indexes
      index_info = described_class.fetch_existing_indexes(class_v2)
      expect(index_info.map { |i| i["name"] }).not_to include('age_height')
      expect(index_info.map { |i| i["name"] }).to include('age')
    end

    it "updates indexes" do
      class_v2 # load class
      MongoOne::AutoIndex.apply_indexes

      class_v3 # load class
      MongoOne::AutoIndex.apply_indexes
      index_info = MongoOne::AutoIndex.fetch_existing_indexes(class_v3).first
      expect(index_info["unique"]).to be(true)
    end
  end
end
