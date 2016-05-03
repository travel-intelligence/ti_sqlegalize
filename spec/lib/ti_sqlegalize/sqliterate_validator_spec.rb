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
end
