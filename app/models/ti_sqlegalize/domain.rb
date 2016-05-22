# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Domain
    include ActiveModel::Model

    attr_accessor :name, :primitive
    alias_attribute :id, :name

    class UnknownDomain < StandardError
    end

    def self.find(id)
      domains = TiSqlegalize.domains.call
      domain = domains[id]
      raise UnknownDomain.new(id) unless domain
      domain
    end
  end
end
