module TiSqlegalize

  class DummyDatabase

    class Cursor < Array

      # Constructor
      #
      # Parameters::
      # * *mocked_data* (Hash<Symbol,Object> or nil): Mocked data information, or nil if no data [default = nil]:
      #   * *schema* (Array< [ String, String ] >): Mocked schema
      #   * *data* (Array<Array>): Array of rows of data to be returned
      def initialize(mocked_data = nil)
        mocked_data = { schema: [], data: [] } if mocked_data.nil?
        @mocked_schema = mocked_data[:schema]
        replace(mocked_data[:data])
        @fetched = false
      end

      # Return the schema of the cursor
      #
      # Result::
      # * Array< [ String, String ] >: List of couples [name, type] of columns
      def schema
        @mocked_schema
      end

      # Close the cursor
      def close
      end

      # Has the cursor more rows to be fetched?
      #
      # Result::
      # * Boolean: Has the cursor more rows to be fetched?
      def has_more?
        if @fetched
          false
        else
          @fetched = true
          true
        end
      end

    end

    # Constructor
    def initialize
      # Mocked data, per statement.
      # See Cursor#initialize to know about mocked data structure.
      # Hash<String, Hash<Symbol,Object> >
      @mocked_statements = {}
    end

    # Execute a given SQL stqtement
    #
    # Parameters::
    # * *statement* (String): The SQL statement to execute
    def execute(statement)
      puts "Mocking data for statement:\n#{statement}\n#{@mocked_statements[statement]}" if @mocked_statements.key?(statement)
      Cursor.new(@mocked_statements[statement])
    end

    # Set dummy data for a given statement
    #
    # Parameters::
    # * *statement* (String): Statement to mock
    # * *mocked_data* (Hash<Symbol,Object>): Mocked data. See Cursor#initialize to know about it.
    def mock_data_for(statement, mocked_data)
      @mocked_statements[statement] = mocked_data
    end

  end

end
