# encoding: utf-8
# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::DomainsController do

  before(:each) { mock_domains }

  let!(:domain) { Fabricate(:domain) }

  context "without and authenticated user" do

    it "requires authentication" do
      get_api :show, id: domain.id
      expect(response.status).to eq(401)
    end

  end

  context "with an authenticated user" do

    let(:user) { Fabricate(:user) }

    before(:each) { sign_in user }

    it "complains on unknown resource" do
      get_api :show, id: "not_a_domain"
      expect(response.status).to eq(404)
      expect(jsonapi_error).to eq("not found")
    end

    it "complains on invalid parameter" do
      get_api :show, id: [1,2,"not_an_id"]
      expect(response.status).to eq(400)
      expect(jsonapi_error).to eq("invalid parameters")
    end

    it "represents a domain" do
      get_api :show, id: domain.id
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('domain')
      expect(jsonapi_id).to eq(domain.id)
      expect(jsonapi_data).to reside_at(v2_domain_url(domain.id))
      expect(jsonapi_attr 'name').to eq('IATA_CITY')
      expect(jsonapi_attr 'primitive').to eq('VARCHAR')

      expect(jsonapi_rel 'relations').to \
        relate_to(v2_domain_relations_url(domain.id))
    end
  end
end
