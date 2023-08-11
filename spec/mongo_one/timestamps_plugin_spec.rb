require 'spec_helper'

RSpec.describe MongoOne::TimestampsPlugin do
  let :dummy_class do
    Class.new do
      include MongoOne
      schema :test_models do
        attribute :name, Types::String
        plugins do
          use MongoOne::TimestampsPlugin
        end
      end
    end
  end

  before do
    MongoOne::Db.configure(database: 'test_db', addr: 'localhost')
    MongoOne.client[:test_models].drop
  end

  after do
    MongoOne::Db.close_connection
  end

  describe 'Timestamps on record creation' do
    it 'assigns created_at and updated_at timestamps' do
      dummy_class.insert_one(name: 'John')
      john = dummy_class.find(name: 'John').limit(1).auto_map.first
      expect(john.created_at).not_to be_nil
      expect(john.updated_at).not_to be_nil
    end
  end

  describe 'Timestamps on record update' do
    it 'updates the updated_at timestamp' do
      dummy_class.insert_one(name: 'John')
      john = dummy_class.find(name: 'John').limit(1).auto_map.first
      dummy_class.update_one({ name: 'John' }, { '$set': { name: 'John Doe' } })
      john_doe = dummy_class.find(name: 'John Doe').limit(1).auto_map.first
      expect(john.updated_at).not_to eq(john_doe.updated_at)
    end
  end
end
