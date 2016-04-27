# encoding: utf-8
require 'spec_helper'
require 'ti_sqlegalize/sqliterate_validator'

RSpec.describe TiSqlegalize::SQLiterateValidator do

  let!(:v) { TiSqlegalize::SQLiterateValidator.new }

  it "validates a correct query" do
    ast = v.parse("select * from t")
    expect(ast.valid?).to eq(true)
  end

  it "validates a incorrect query" do
    ast = v.parse("this is not a valid SQL query")
    expect(ast.valid?).to eq(false)
  end

  it "validates a correct query" do
    ast = v.parse("select a from t1, (select b,c from d.t) t2")
    expect(ast.tables).to eq(["d.t", "t1"])
  end

  it "normalize a query" do
    pending("Normalization not implemented in SQLiterateValidator")
    ast = v.parse("select a from t1, (select b,c from d.t) t2")
    expect(ast.sql).to eq("TBD")
  end
end
