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
end

RSpec.configure do |c|
  c.include SampleSchemas
end
