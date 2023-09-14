class Comment < Dry::Struct
  attribute :body, Types::String
  attribute :author, Types::String
end

class Post < Dry::Struct
  attribute :title, Types::Strict::String
  attribute :body, Types::Strict::String
  attribute :tags, Types::Array.of(Types::Strict::String)
  attribute :comments, Types::Array.of(Comment)
end

class User < Dry::Struct
  attribute :_id, Types::Any
  attribute? :name, Types::Strict::String
  attribute :age, Types::Strict::Integer
  attribute :posts, Types::Array.of(Post)
end

class UserProjectionCollection
  include MongoOne
  schema :users do
    attribute :traits, Types::Hash do
      attribute :age, Types::Integer
      attribute? :height, Types::Integer
      attribute :book, Types::Hash do
        attribute :title, Types::String.optional
      end
    end
  end
end

describe MongoOne::ProjectionBuilder do
  describe '#fields' do
    context 'when the class is User' do
      let(:user_projection_builder) { described_class.new(User) }

      it 'returns the correct projection' do
        expected_projection = {
          '_id' => 1,
          'name' => 1,
          'age' => 1,
          'posts.title' => 1,
          'posts.body' => 1,
          'posts.tags' => 1,
          'posts.comments.body' => 1,
          'posts.comments.author' => 1
        }

        expect(user_projection_builder.fields).to eq(expected_projection)
      end
    end

    context 'when the class is Post' do
      let(:post_projection_builder) { described_class.new(Post) }

      it 'returns the correct projection' do
        expected_projection = {
          'title' => 1,
          'body' => 1,
          'tags' => 1,
          'comments.body' => 1,
          'comments.author' => 1
        }

        expect(post_projection_builder.fields).to eq(expected_projection)
      end
    end

    context 'when the class is MongoOne auto_struct' do
      let(:user_collection_projection_builder) { described_class.new(UserProjectionCollection::Struct) }

      it 'returns the correct projection for MongoOne auto_struct' do
        expected_projection = {
          '_id' => 1,
          'traits.age' => 1,
          'traits.height' => 1,
          'traits.book.title' => 1
        }
        expect(user_collection_projection_builder.fields).to eq(expected_projection)
      end
    end
  end
end
