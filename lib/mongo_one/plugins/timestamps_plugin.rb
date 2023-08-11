module MongoOne
  class TimestampsPlugin < Plugin
    def apply
      add_attribute(:created_at)
      add_attribute(:updated_at)

      define_touch_many_method
    end

    def before_create(document_or_documents)
      time_now = current_time_in_milliseconds
      document_or_documents = [document_or_documents] if document_or_documents.is_a?(Hash)
      document_or_documents.each do |doc|
        set_time(doc, :created_at, time_now)
        set_time(doc, :updated_at, time_now)
      end
    end

    def before_update(document_or_pipeline)
      if document_or_pipeline.is_a?(Array)
        was_set = false
        document_or_pipeline.each do |doc|
          next unless doc[:$set]

          doc[:$set][:updated_at] = current_time_in_milliseconds
        end
        raise ArgumentError, 'You must use $set operator in the update_pipeline method' unless was_set
      end
      raise ArgumentError, 'You must use $set operator in update method' unless document_or_pipeline[:$set]

      document_or_pipeline[:$set][:updated_at] = current_time_in_milliseconds
    end

    private

    def add_attribute(name)
      klass.attribute(name, Types::Integer) unless klass.attributes.key?(name)
    end

    def define_touch_many_method
      klass.extended_class.define_singleton_method(:touch_many) do |query|
        value = { updated_at: current_time_in_milliseconds }
        klass.collection.update_many(query, { '$set': value })
      end
    end

    def set_time(document, attribute, time)
      document[attribute] ||= time
    end

    def current_time_in_milliseconds
      (Time.now.to_f * 1000).to_i
    end
  end
end
