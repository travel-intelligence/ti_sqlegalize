# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Table
    include ActiveModel::Model

    attr_accessor :name, :columns
    attr_reader :id

    validates :name, presence: true

    class UnknownTable < StandardError
    end

    def self.find(id)
      table = TiSqlegalize.schemas.find_table id
      raise UnknownTable.new(id) unless table
      table
    end

    def initialize(attributes={})
      super
      @id = SecureRandom.uuid
      @columns ||= []
    end
  end
end
