# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::HeadingsController do

  let!(:query) { Fabricate(:finished_query) }

  context "without and authenticated user" do

    it "requires authentication" do
      get_api :show_by_query, query_id: query.id, attr_id: 'a'
      expect(response.status).to eq(401)
    end

  end

  context "with an authenticated user" do

    let(:user) { Fabricate(:user) }

    before(:each) do
      mock_domains
      sign_in user
    end

    it "complains on unknown resource" do
      get_api :show_by_query, query_id: "not_a_query", attr_id: 'a'
      expect(response.status).to eq(404)
      expect(jsonapi_error).to eq("not found")
    end

    it "complains on invalid parameter" do
      get_api :show_by_query, query_id: [1,2,"not_an_id"], attr_id: 'a'
      expect(response.status).to eq(400)
      expect(jsonapi_error).to eq("invalid parameters")
    end

    it "complains when not ready" do
      unfinished_query = Fabricate(:created_query)
      get_api :show_by_query, query_id: unfinished_query.id, attr_id: 'a'
      expect(response.status).to eq(409)
      expect(jsonapi_error).to eq("conflict")
    end

    it "fetches a query attribute" do
      get_api :show_by_query, query_id: query.id, attr_id: 'a'
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('domain')
      expect(jsonapi_id).to eq('IATA_CITY')
      expect(jsonapi_data).to \
        reside_at(v2_domain_url('IATA_CITY'))
      expect(jsonapi_attr 'name').to eq('IATA_CITY')
      expect(jsonapi_attr 'primitive').to eq('VARCHAR')
      expect(jsonapi_rel 'relations').to \
        relate_to(v2_domain_relations_url('IATA_CITY'))
    end
  end
end
