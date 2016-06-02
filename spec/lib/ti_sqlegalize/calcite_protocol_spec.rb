# encoding: utf-8
require 'rails_helper'
require 'ti_sqlegalize/calcite_validator'

RSpec.describe TiSqlegalize::CalciteValidator do

  before(:each) do
    mock_domains
    mock_schemas
  end

  let(:simple_sql) { "select * from hr.emps" }

  it "formats validation requests" do
    schemas = [TiSqlegalize.schemas['HR']]
    req = TiSqlegalize::CalciteValidator::ValidationRequest.new(simple_sql, schemas)

    expect_json(req.message, [
      ['$.validation.sql', eq(simple_sql)],
      ['$.validation.schemas[0].name', eq("HR")],
      ['$.validation.schemas[0].tables[0].name', eq("EMPS")],
      ['$.validation.schemas[0].tables[0].columns[0].name', eq("EMPID")],
      ['$.validation.schemas[0].tables[0].columns[0].type', eq("INTEGER")]
    ])
  end

  it "parses validation response" do

    msg = {
      "validation": {
        "valid": true,
        "sql": simple_sql,
        "hint": "nothing to say"
      }
    }.to_json

    rep = TiSqlegalize::CalciteValidator::ValidationResponse.new(msg)

    expect(rep).to be_valid
    expect(rep.sql).to eq(simple_sql)
    expect(rep.hint).to eq("nothing to say")
  end

  it "rejects non-JSON response" do
    expect do
      TiSqlegalize::CalciteValidator::ValidationResponse.new("not json")
    end.to raise_error(JSON::ParserError)
  end

  it "rejects invalid JSON response" do
    expect do
      TiSqlegalize::CalciteValidator::ValidationResponse.new("{}")
    end.to raise_error(TiSqlegalize::CalciteValidator::InvalidResponse)
  end
end
