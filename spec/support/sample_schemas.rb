# encoding: utf-8
module SampleSchemas
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
    ].map { |d| [d.name, d] }]

    allow(TiSqlegalize).to \
      receive(:domains).and_return(-> { domains })
  end
end

RSpec.configure do |c|
  c.include SampleSchemas
end
