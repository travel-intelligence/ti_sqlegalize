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

    class InvalidResponse < StandardError
    end

    class ValidationResponse
      def initialize(msg)
        m = ActiveSupport::JSON.decode msg
        fail InvalidResponse unless m["validation"]
        @valid = m["validation"]["valid"]
        @sql = m["validation"]["sql"]
        @hint = m["validation"]["hint"]
      end

      def valid?
        @valid
      end

      def sql
        @sql
      end

      def hint
        @hint
      end
    end

    def initialize(socket)
      @socket = socket
    end

    def parse(sql, schemas)
      req = ValidationRequest.new(sql, schemas).message
      rep = @socket.response_for req
      ValidationResponse.new(rep)
    end
  end
end
