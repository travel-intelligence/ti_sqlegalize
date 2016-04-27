
module TiSqlegalize
  class DummyDatabase
    class Cursor < Array
      def schema; [] end
      def close; end
    end
    def execute(_statement)
      Cursor.new
    end
  end
end
