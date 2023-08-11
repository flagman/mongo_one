module MongoOne
  module Db
    class << self
      attr_accessor :client, :db, :config, :valid_config_keys
    end

    self.config = { addr: "localhost", database: "my_database", logger: nil, max_pool_size: 5, read_mode: :primary }
    self.valid_config_keys = @config.keys

    def self.configure(opts = {})
      opts.each { |k, v| config[k.to_sym] = v if valid_config_keys.include? k.to_sym }
    end

    def self.configure_with(path_to_yaml_file)
      begin
        config_from_file = YAML.safe_load_file(path_to_yaml_file)
      rescue StandardError => e
        raise "YAML configuration file couldn't be found: #{e}"
      end
      configure(config_from_file)
    end

    def self.[](key)
      client[key]
    end

    def self.establish_connection
      Mongo::Logger.logger.level = ::Logger::FATAL
      self.client = Mongo::Client.new(
        "mongodb://#{config[:addr]}",
        database: config[:database],
        read: { mode: config[:read_mode]&.to_sym },
        max_pool_size: config[:max_pool_size]
      )
      self.db = client.database
    end

    def self.close_connection
      client.close
      self.db = nil
    end
  end
end
