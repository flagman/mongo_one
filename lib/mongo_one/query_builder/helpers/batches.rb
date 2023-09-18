module MongoOne
  module QueryBuilder
    module Helpers
      module Batches
        def each_batch(fetch_size, batch_size: fetch_size)
          raise ArgumentError, "batch_size should not be greater than fetch_size" if batch_size > fetch_size

          pre_skip = options[:skip] || 0
          Enumerator.new do |yielder|
            total_fetched = 0
            total_limit = options[:limit] || collection.count(filter)
            buffer = []

            loop do
              items = fetch_next_batch(total_fetched, fetch_size, total_limit, pre_skip)
              break if items.empty?

              total_fetched += items.size
              buffer.concat(items)

              last_batch = items.size < fetch_size || total_fetched >= total_limit
              process_buffer(yielder, buffer, batch_size, last_batch)

              break if last_batch
            end
          end
        end

        private

        # Process the buffer and yield results
        def process_buffer(yielder, buffer, batch_size, last_batch)
          while buffer.any?
            size_to_shift = [buffer.size, batch_size].min
            break unless last_batch || size_to_shift == batch_size

            to_yield = batch_size == 1 ? buffer.shift : buffer.shift(size_to_shift)
            yielder.yield(to_yield)
          end
        end

        # Fetch the next batch of items
        def fetch_next_batch(total_fetched, fetch_size, total_limit, pre_skip)
          current_fetch_size = [0, fetch_size, total_limit - total_fetched].max
          return [] if current_fetch_size.zero?

          build_subquery(total_fetched + pre_skip, current_fetch_size).all
        end

        # Build a subquery for fetching items
        def build_subquery(skipped, current_fetch_size)
          subquery = self.class.new(instance_variable_get(:@klass))
          subquery.find(filter.clone, options.clone)
          subquery.skip(skipped).limit(current_fetch_size)
          subquery.sort(options[:sort]) if options[:sort]
          subquery.aggregation_pipeline = aggregation_pipeline
          subquery.map_to(_map_class)
          subquery
        end
      end
    end
  end
end
