# encoding: utf-8
require 'spec_helper'
require 'ti_sqlegalize/calcite_validator'

RSpec.describe TiSqlegalize::CalciteValidator do

  let!(:v) { TiSqlegalize::CalciteValidator.new }

  xit "validates a correct query" do
    ast = v.parse("select * from t")
    expect(ast.valid?).to eq(true)
  end

  xit "validates a incorrect query" do
    ast = v.parse("this is not a valid SQL query")
    expect(ast.valid?).to eq(false)
  end

  it "validates a correct query" do
    pending("Tables extraction not implemented in CalciteValidator")
    ast = v.parse("select a from t1, (select b,c from d.t) t2")
    expect(ast.tables).to eq(["d.t", "t1"])
  end

  xit "normalize a query" do
    ast = v.parse("select a from t1, (select b,c from d.t) t2")
    expect(ast.sql).to eq("TBD")
  end
end
