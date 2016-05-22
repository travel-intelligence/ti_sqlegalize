# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::RelationsController do

  let!(:query) { Fabricate(:finished_query) }

  context "without and authenticated user" do

    it "requires authentication" do
      get_api :show, query_id: query.id
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
      get_api :show, query_id: "not_a_query"
      expect(response.status).to eq(404)
      expect(jsonapi_error).to eq("not found")
    end

    it "complains on invalid parameter" do
      get_api :show, query_id: [1,2,"not_an_id"]
      expect(response.status).to eq(400)
      expect(jsonapi_error).to eq("invalid parameters")
    end

    it "complains when not ready" do
      unfinished_query = Fabricate(:created_query)
      get_api :show, query_id: unfinished_query.id
      expect(response.status).to eq(409)
      expect(jsonapi_error).to eq("conflict")
    end

    it "fetches a query result" do
      get_api :show, query_id: query.id
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('relation')
      expect(jsonapi_id).to eq(query.id)
      expect(jsonapi_data).to reside_at(v2_query_result_url(query.id))
      expect(jsonapi_attr 'sql').to eq(query.statement)
      expect(jsonapi_attr 'heading').to eq(['a'])

      expect(jsonapi_rel 'heading_a').to \
        relate_to(v2_query_result_heading_url(query.id, 'a'))

      expect(jsonapi_rel 'heading_a').to \
        be_identified_by('domain' => 'IATA_CITY')

      expect(jsonapi_rel 'body').to \
        relate_to(v2_query_result_body_url(query.id))

      iata_city = jsonapi_inc 'domain', 'IATA_CITY'
      expect(jsonapi_attr 'name', iata_city).to eq('IATA_CITY')
    end
  end
end
