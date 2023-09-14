RSpec.describe "MongoOne integration" do
  before do
    MongoOne::Db.configure(database: 'test_db', addr: 'localhost')
    MongoOne::Db.establish_connection
    MongoOne.client[:users].drop
  end

  after do
    MongoOne::Db.close_connection
  end

  let(:user_collection) do
    Class.new do
      include MongoOne
      schema :users do
        attribute :name, Types::String
        attribute :age, Types::Integer.optional
        attribute :cars, Types::Array do
          attribute :model, Types::String
          attribute? :year, Types::Integer  # tolarance to missing attribute
        end
        attribute :traits, Types::Hash do
          attribute :age, Types::Integer
          attribute :height, Types::Integer
          attribute :book, Types::Hash do
            attribute :title, Types::String
          end
        end
      end
    end
  end

  it "queries and maps a document to a Ruby object" do
    # tested_class = user_collection
    user_collection.insert_one(name: 'John',
                               age: nil,
                               cars: [{ model: 'Tesla' }, { model: 'BMW', year: 2015 }],
                               traits: { age: 30, height: 180, book: { title: 'The Martian' } })
    user = user_collection.find(name: 'John').limit(1).one
    expect(user.name).to eq('John')
  end

  it "can be used via instance methods" do
    uc = user_collection.new
    uc.insert_one(name: 'John',
                  age: nil,
                  cars: [{ model: 'Tesla', year: 2018 }, { model: 'BMW', year: 2015 }],
                  traits: { age: 30, height: 180, book: { title: 'The Martian' } })
    user = uc.find(name: 'John').limit(1).one
    expect(user.name).to eq('John')
  end
end
