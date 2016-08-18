# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::Table do

  before(:each) do
    mock_domains
    mock_schemas
  end

  let!(:table) { Fabricate(:table) }

  it "complains on unknown table" do
    expect do
      TiSqlegalize::Table.find 'not_a_table'
    end.to raise_error(TiSqlegalize::Table::UnknownTable)
  end

  it "fetches an existing table" do
    expect(TiSqlegalize::Table.find table.id).to eq(table)
  end

  it "contains columns" do
    columns = table.columns
    expect(columns.size).to eq(1)
  end

  it "finds its current schema" do
    schema = table.schema
    expect(schema).to eq(Fabricate(:schema))
  end

  it "complains for orphan table" do
    expect do
      TiSqlegalize::Table.new.schema
    end.to raise_error(TiSqlegalize::Table::UnknownTable)
  end
end
