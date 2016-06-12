# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Domain
    include ActiveModel::Model

    attr_accessor :name, :primitive
    alias_attribute :id, :name

    validates :name, presence: true
    validates :primitive, presence: true

    class UnknownDomain < StandardError
    end

    def self.find(id)
      domain = TiSqlegalize::Config.domains[id]
      raise UnknownDomain.new(id) unless domain
      domain
    end
  end
end
