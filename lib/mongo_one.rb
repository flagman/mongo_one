module MongoOne
  INCLUDED_IN = []
  def self.included(base)
    base.extend(ClassMethods)
    included_in(base)
  end

  def self.client
    Db.client
  end

  def self.testing?
    ENV['RACK_ENV'] == 'test'
  end

  def self.included_in(base = nil)
    INCLUDED_IN << base if base
    INCLUDED_IN
  end
end

require 'dry-types'
require 'dry-struct'
require 'mongo'
require 'mongo_one/version'
require 'mongo_one/class_methods'
require 'mongo_one/db'
require 'mongo_one/query_builder/base'
require 'mongo_one/query_builder/read_operations'
require 'mongo_one/query_builder/write_operations'
require 'mongo_one/query_builder/delete_operations'
require 'mongo_one/query_builder/options_chain'
require 'mongo_one/query_builder/query'
require 'mongo_one/schema_builder'
require 'mongo_one/plugins_builder'
require 'mongo_one/plugin'
require 'mongo_one/plugins/timestamps_plugin'
require 'mongo_one/types'
require 'mongo_one/index_builder'
require 'mongo_one/projection_builder'
require 'mongo_one/ast/parser'
require 'mongo_one/auto_index'
