# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::QueriesController do

  let(:sql) { "select a from t1, (select b,c from d.t) t2" }
  let(:rep) do
    {
      data: {
        type: 'query',
        attributes: {
          sql: sql
        }
      }
    }
  end

  context "without and authenticated user" do

    it "requires authentication" do
      post_api :create, rep
      expect(response.status).to eq(401)
    end

  end

  context "with an authenticated user" do

    let(:user) { Fabricate(:user) }

    before(:each) { sign_in user }

    it "creates a query" do
      post_api :create, rep
      expect(response.status).to eq(201)
      location = response.headers['Location']
      expect(location).not_to be_blank
      expect(jsonapi_type).to eq('query')
      expect(jsonapi_id).not_to be_nil
      expect(jsonapi_data).to reside_at(v2_query_url(jsonapi_id))
      expect(jsonapi_attr 'status').to eq('created')
      expect(jsonapi_attr 'sql').to eq(sql)
    end

    it "complains on unknown resource" do
      get_api :show, id: "not_a_query"
      expect(response.status).to eq(404)
      expect(jsonapi_error).to eq("not found")
    end

    it "complains on invalid parameter" do
      get_api :show, id: [1,2,"not_an_id"]
      expect(response.status).to eq(400)
      expect(jsonapi_error).to eq("invalid parameters")
    end

    it "fetches an unfinished query" do
      query = Fabricate(:created_query)

      get_api :show, id: query.id
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('query')
      expect(jsonapi_id).to eq(query.id)
      expect(jsonapi_data).to reside_at(v2_query_url(query.id))
      expect(jsonapi_attr 'status').to eq('created')
      expect(jsonapi_attr 'sql').to eq(query.statement)
      expect(jsonapi_rel 'result').to be_nil
    end

    it "fetches a finished query" do
      query = Fabricate(:finished_query)

      get_api :show, id: query.id
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('query')
      expect(jsonapi_id).to eq(query.id)
      expect(jsonapi_data).to reside_at(v2_query_url(query.id))
      expect(jsonapi_attr 'status').to eq('finished')
      expect(jsonapi_attr 'sql').to eq(query.statement)
      expect(jsonapi_rel 'result').to relate_to(v2_query_result_url(query.id))
    end
  end
end
