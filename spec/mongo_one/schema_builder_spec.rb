RSpec.describe MongoOne::SchemaBuilder do
  describe '#attribute' do
    let(:dummy_class) { Class.new }
    let(:schema_builder) { described_class.new(dummy_class) }

    context 'when defining a simple attribute' do
      it 'defines an attribute with the given type' do
        schema_builder.attribute(:name, Types::String)
        expect(schema_builder.attributes).to include(name: { type: Types::String })
      end
    end

    context 'when defining a nested attribute' do
      it 'defines a nested attribute with the given type and nested structure' do
        schema_builder.attribute(:address, Types::Hash) do
          attribute :city, Types::String
          attribute :zip, Types::Integer
        end
        schema_builder.attributes[:address][:type].keys.map(&:name).each do |key|
          expect(%i[city zip]).to include(key)
        end
      end
    end
  end

  describe '#attribute?' do
    let(:dummy_class) { Class.new }
    let(:schema_builder) { described_class.new(dummy_class) }

    it 'defines an attribute with given name and ? as symbol' do
      schema_builder.attribute?(:name, Types::String)
      expect(schema_builder.attributes).to include(name?: { type: Types::String })
    end
  end

  describe '#indexes' do
    let(:dummy_class) do
      Class.new do
        include MongoOne
      end
    end
    let(:schema_builder) { described_class.new(dummy_class) }

    it 'defines an index on the given fields' do
      schema_builder.indexes do
        index :hash, keys: { hash: 1 }, options: { unique: true }
      end
      expect(dummy_class.indexes).to eq([{ "key" => { "hash" => 1 }, "name" => "hash", "unique" => true }])
    end
  end

  describe '#apply_schema' do
    let(:dummy_class) do
      Class.new do
        include MongoOne
      end
    end

    it 'applies the defined schema to the class' do
      dummy_class.schema 'test' do
        attribute :name, Types::String
      end
      expect(dummy_class.const_defined?(:Struct)).to be true
    end
  end
end
