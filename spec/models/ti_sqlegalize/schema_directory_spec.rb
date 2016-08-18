# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::SchemaDirectory do

  before(:each) { mock_domains }

  let(:directory) do
    TiSqlegalize::SchemaDirectory.load(
      File.join(Rails.root, '..', 'schemas.json')
    )
  end

  it "loads schemas" do
    expect(directory.size).to eq(2)
  end

  it "lookup schemas" do
    schema = directory['MARKET']
    expect(schema).not_to be_nil
    expect(schema.name).to eq('MARKET')
    expect(schema.description).to eq('Market schema')
    expect(schema.tables.size).to eq(1)

    table = schema.tables.first
    expect(table.name).to eq('BOOKINGS_OND')
    expect(table.columns.size).to eq(1)

    column = table.columns.first
    expect(column.name).to eq('BOARD_CITY')
    expect(column.domain.name).to eq('IATA_CITY')
    expect(column.domain.primitive).to eq('VARCHAR')
  end

  it "lookup a table by id" do
    table = directory['MARKET'].tables.first
    expect(directory.find_table(table.id)).to eq(table)
  end

  it "lookup an unknown table by id" do
    table = TiSqlegalize::Table.new
    expect(directory.find_table(table.id)).to be_nil
  end

  it "returns all schemas" do
    expect(directory.all.size).to eq(2)
  end

  it "lookup schema by table" do
    schema = directory['MARKET']
    table = schema.tables.first
    expect(directory.find_table_schema(table.id)).to eq(schema)
  end

  it "lookup schema by unknown table" do
    table = TiSqlegalize::Table.new
    expect(directory.find_table_schema(table.id)).to be_nil
  end
end
