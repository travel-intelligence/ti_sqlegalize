# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Schema
    include ActiveModel::Model

    attr_accessor :name, :description, :tables
    alias_attribute :id, :name

    validates :name, presence: true

    class UnknownSchema < StandardError
    end

    def self.find(id)
      schema = TiSqlegalize::Config.schemas[id]
      raise UnknownSchema.new(id) unless schema
      schema
    end

    def self.all
      TiSqlegalize::Config.schemas.all
    end

    def initialize(attributes={})
      super
      @tables ||= []
    end
  end
end
