# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::QueriesController do

  let(:rep) do
    {
      data: {
        type: 'query',
        attributes: {
          sql: "select a from t1, (select b,c from d.t) t2"
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

    let!(:user) { Fabricate(:user) }
    before(:each) { sign_in user }

    it "creates a query" do
      post_api :create, rep
      expect(response.status).to eq(201)
      location = response.headers['Location']
      expect(location).not_to be_blank
      expect(jsonapi_type).to eq('query')
      expect(jsonapi_id).not_to be_nil
      expect(jsonapi_data).to reside_at(v2_query_url(jsonapi_id))
    end
  end
end
