# encoding: utf-8

Fabricator(:domain, class_name: TiSqlegalize::Domain) do
  initialize_with { TiSqlegalize::Domain.find 'IATA_CITY' }
end
