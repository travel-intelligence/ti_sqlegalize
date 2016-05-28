# encoding: utf-8
module SchemaHelper
  def hr_schema
    {
      "name" => "HR",
      "tables" => [{
        "name" => "EMPS",
        "columns" => [
          { "name" => "EMPID", "type" => "INTEGER" },
          { "name" => "EMPNAME", "type" => "VARCHAR" },
          { "name" => "DEPTNO", "type" => "INTEGER" }
        ]
      }]
    }
  end

  def mock_domains
    domains = Hash[[
      TiSqlegalize::Domain.new(name: 'IATA_CITY', primitive: 'VARCHAR')
    ].map { |d| [d.id, d] }]

    allow(TiSqlegalize).to \
      receive(:domains).and_return(-> { domains })
  end

  def mock_schemas
    schemas = Hash[[
      TiSqlegalize::Schema.new(
        name: 'MARKET',
        description: 'Market schema',
        tables: [
          TiSqlegalize::Table.new(
            name: 'BOOKINGS_OND',
            columns: [
              TiSqlegalize::Column.new(name: 'BOARD_CITY', domain: 'IATA_CITY')
            ]
          )
        ]
      )
    ].map { |d| [d.id, d] }]

    allow(TiSqlegalize).to \
      receive(:schemas).and_return(-> { schemas })
  end
end

RSpec.configure do |c|
  c.include SchemaHelper
end
