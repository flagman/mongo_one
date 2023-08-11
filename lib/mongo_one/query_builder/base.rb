module MongoOne
  module QueryBuilder
    class Base
      attr_reader :collection, :filter, :options

      def initialize(klass)
        @klass = klass
        @collection = klass.collection
        @filter = {}
        @options = {}
      end
    end
  end
end
