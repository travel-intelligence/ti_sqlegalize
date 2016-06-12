# encoding: utf-8
module SchemaHelper
  def mock_domains
    directory = TiSqlegalize::DomainDirectory.load(
                  File.join(Rails.root, '..', 'domains.json')
                )

    allow(TiSqlegalize::Config).to receive(:domains).and_return(directory)
  end

  def mock_schemas
    directory = TiSqlegalize::SchemaDirectory.load(
                  File.join(Rails.root, '..', 'schemas.json')
                )

    allow(TiSqlegalize::Config).to receive(:schemas).and_return(directory)
  end

  def mock_validator(validator=nil)
    validator ||= TiSqlegalize::SQLiterateValidator.new

    allow(TiSqlegalize::Config).to receive(:validator).and_return(validator)
  end

  def mock_cursor(schema, rows)
    cursor = double("cursor")
    allow(cursor).to receive(:each_slice) { |_, &blk| blk.call rows }
    allow(cursor).to receive(:open?).and_return(true)
    allow(cursor).to receive(:close)
    allow(cursor).to receive(:schema).and_return(schema)
    cursor
  end
end

RSpec.configure do |c|
  c.include SchemaHelper
end
