require "ti_sqlegalize/engine"

module TiSqlegalize
  extend self

  class DummyDatabase
    def execute(statement)
      []
    end
  end

  def database=(e)
    @database = e
  end

  def database
    return @database if @database
    self.database = DummyDatabase.new
  end
end
