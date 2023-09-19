module MongoOne
  module QueryBuilder
    class Query < Base
      include QueryBuilder::ReadOperations
      include QueryBuilder::WriteOperations
      include QueryBuilder::DeleteOperations
      include QueryBuilder::OptionsChain
      include QueryBuilder::Helpers::Batches
    end
  end
end
