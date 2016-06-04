# encoding: utf-8

Fabricator(:created_query, class_name: TiSqlegalize::Query) do
  initialize_with do
    q = TiSqlegalize::Query.new 'select a from t'
    q.create!
    q
  end
end

Fabricator(:finished_query, class_name: TiSqlegalize::Query) do
  initialize_with do
    q = TiSqlegalize::Query.new 'select a from t'
    q.create!
    q.schema = [
      TiSqlegalize::Column.new(
        name: 'a',
        domain: TiSqlegalize::Domain.find('IATA_CITY')
      )
    ]
    q << [['MAD'],['NCE'],['BOS'],['MUC']]
    q.status = :finished
    q.save!
    q
  end
end
