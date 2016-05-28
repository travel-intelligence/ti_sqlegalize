# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Table
    include ActiveModel::Model

    attr_accessor :name, :columns
    attr_reader :id

    class UnknownTable < StandardError
    end

    def self.find(id)
      schemas = TiSqlegalize.schemas.call
      table = schemas.map { |_,s| s.tables.find { |t| t.id == id } }.find { |t| t }
      raise UnknownTable.new(id) unless table
      table
    end

    def initialize(attributes={})
      super
      @id = SecureRandom.uuid
    end
  end
end
