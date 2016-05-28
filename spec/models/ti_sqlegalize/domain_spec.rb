# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::Domain do

  before(:each) { mock_domains }

  it "complains on unknown domain" do
    expect do
      TiSqlegalize::Domain.find 'not_a_domain'
    end.to raise_error(TiSqlegalize::Domain::UnknownDomain)
  end

  it "fetches an existing domain" do
    domain = Fabricate(:domain)
    expect(TiSqlegalize::Domain.find domain.id).to eq(domain)
  end
end
