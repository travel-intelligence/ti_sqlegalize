# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class Column
    include ActiveModel::Model

    attr_accessor :name, :domain
    alias_attribute :id, :name
  end
end
