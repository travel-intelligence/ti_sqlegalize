# encoding: utf-8

class User

  attr_accessor :schemas

  def initialize
    @schemas = []
  end

  def can_read_schema?(schema)
    @schemas.include? schema.id
  end
end
