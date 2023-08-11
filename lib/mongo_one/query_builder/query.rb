module MongoOne
  module QueryBuilder
    class Query < Base
      include QueryBuilder::ReadOperations
      include QueryBuilder::WriteOperations
      include QueryBuilder::DeleteOperations
      include QueryBuilder::OptionsChain
    end
  end
end
