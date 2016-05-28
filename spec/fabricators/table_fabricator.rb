# encoding: utf-8

Fabricator(:table, class_name: TiSqlegalize::Table) do
  initialize_with { TiSqlegalize::Schema.find('MARKET').tables.first }
end
