module MongoOne
  module QueryBuilder
    module OptionsChain
      def hint(index_name)
        options[:hint] = index_name.to_s
        self
      end

      def limit(value)
        options[:limit] = value
        self
      end
    end
  end
end
