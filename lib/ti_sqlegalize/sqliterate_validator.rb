module TiSqlegalize
  class SQLiterateAst
    def initialize(sql, ast)
      @sql = sql
      @ast = ast
    end

    def valid?
      ! @ast.nil?
    end

    def sql
      @sql
    end

    def tables
      @ast.tables
    end
  end

  class SQLiterateValidator
    def initialize
      @parser = SQLiterate::QueryParser.new
    end

    def parse(sql)
      SQLiterateAst.new sql, @parser.parse(sql)
    end
  end
end
