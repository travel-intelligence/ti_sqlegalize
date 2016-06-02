# encoding: utf-8
require 'sqliterate'

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

    def hint
      ""
    end
  end

  class SQLiterateValidator
    def initialize
      @parser = SQLiterate::QueryParser.new
    end

    def parse(sql, _schemas=nil)
      SQLiterateAst.new sql, @parser.parse(sql)
    end
  end
end
