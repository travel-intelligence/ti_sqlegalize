module TiSqlegalize
  class CalciteAst
    def initialize(sql)
      @sql = sql
    end

    def valid?
      true
    end

    def tables
      []
    end

    def sql
      @sql
    end
  end

  class CalciteValidator
    def parse(sql)
      CalciteAst.new sql
    end
  end
end
