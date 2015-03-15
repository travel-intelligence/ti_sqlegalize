require "ti_sqlegalize/engine"

module TiSqlegalize
  extend self

  class DummyDatabase
    class Cursor < Array
      def schema; [] end
      def close; end
    end
    def execute(_statement)
      Cursor.new
    end
  end

  def database=(e)
    @database = e
  end

  def database
    return @database if @database
    self.database = ->() { DummyDatabase.new }
  end
end
