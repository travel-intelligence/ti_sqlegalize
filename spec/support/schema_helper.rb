# encoding: utf-8
module SchemaHelper
  def mock_domains
    directory = TiSqlegalize::DomainDirectory.load(
                  File.join(Rails.root, '..', 'domains.json')
                )

    allow(TiSqlegalize).to \
      receive(:domains).and_return(directory)
  end

  def mock_schemas
    directory = TiSqlegalize::SchemaDirectory.load(
                  File.join(Rails.root, '..', 'schemas.json')
                )

    allow(TiSqlegalize).to \
      receive(:schemas).and_return(directory)
  end
end

RSpec.configure do |c|
  c.include SchemaHelper
end
