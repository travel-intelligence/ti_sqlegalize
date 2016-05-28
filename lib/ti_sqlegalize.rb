# encoding: utf-8
require "ti_sqlegalize/engine"
require "ti_sqlegalize/dummy_database"
require "ti_sqlegalize/sqliterate_validator"

module TiSqlegalize
  extend self

  def database=(e)
    @database = e
  end

  def database
    return @database if @database
    self.database = ->() { DummyDatabase.new }
  end

  def validator=(v)
    @validator = v
  end

  def validator
    return @validator if @validator
    self.validator = -> { SQLiterateValidator.new }
  end

  def schemas=(s)
    @schemas = s
  end

  def schemas
    return @schemas if @schemas
    self.schemas = -> { {} }
  end

  def domains=(d)
    @domains = d
  end

  def domains
    return @domains if @domains
    self.domains = -> { {} }
  end
end
