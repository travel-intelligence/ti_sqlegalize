# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::SchemaDirectory do

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
    expect(column.domain).to eq('IATA_CITY')
  end

  it "lookup tables by id" do
    table = directory['MARKET'].tables.first
    expect(directory.find_table(table.id)).to eq(table)
  end

  it "returns all schemas" do
    expect(directory.all.size).to eq(2)
  end
end
