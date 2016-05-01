module TiSqlegalize

  class CalciteValidator

    class ValidationRequest
      def initialize(sql, schemas)
        @sql = sql
        @schemas = schemas
      end

      def message
        {
          "validation" => {
            "sql" => @sql,
            "schemas" => @schemas
          }
        }.to_json
      end
    end

    class ValidationResponse
      def initialize(msg)
        m = ActiveSupport::JSON.decode msg
        fail "Invalid response" unless m["validation"]
        @valid = m["validation"]["valid"]
        @sql = m["validation"]["sql"]
      end

      def valid?
        @valid
      end

      def tables
        []
      end

      def sql
        @sql
      end
    end

    def initialize(socket)
      @socket = socket
    end

    def parse(sql, schemas)
      req = ValidationRequest.new(sql, schemas).message
      @socket << req
      rep = @socket.receive
      ValidationResponse.new(rep.pop)
    end
  end
end
