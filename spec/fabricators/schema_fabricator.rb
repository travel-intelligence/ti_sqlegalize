# encoding: utf-8

Fabricator(:schema, class_name: TiSqlegalize::Schema) do
  initialize_with { TiSqlegalize::Schema.find 'MARKET' }
end
