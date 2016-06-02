# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::DomainDirectory do

  let(:directory) do
    TiSqlegalize::DomainDirectory.load(
      File.join(Rails.root, '..', 'domains.json')
    )
  end

  it "loads domains" do
    expect(directory.size).to eq(3)
  end

  it "lookup domains" do
    domain = directory['IATA_CITY']
    expect(domain).not_to be_nil
    expect(domain.name).to eq('IATA_CITY')
    expect(domain.primitive).to eq('VARCHAR')
  end
end
