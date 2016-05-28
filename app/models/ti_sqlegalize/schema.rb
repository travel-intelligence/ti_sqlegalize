# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Schema
    include ActiveModel::Model

    attr_accessor :name, :description, :tables
    alias_attribute :id, :name

    class UnknownSchema < StandardError
    end

    def self.find(id)
      schemas = TiSqlegalize.schemas.call
      schema = schemas[id]
      raise UnknownSchema.new(id) unless schema
      schema
    end

    def self.all
      schemas = TiSqlegalize.schemas.call
      schemas.values
    end
  end
end
