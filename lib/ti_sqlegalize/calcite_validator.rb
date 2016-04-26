module TiSqlegalize
  class CalciteAst
    def tables
      []
    end
  end

  class CalciteValidator
    def parse(sql)
      CalciteAst.new
    end
  end
end
