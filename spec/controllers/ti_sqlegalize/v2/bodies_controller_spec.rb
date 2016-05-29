# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::BodiesController do

  context "on a query" do

    let!(:query) { Fabricate(:finished_query) }

    context "without and authenticated user" do

      it "requires authentication" do
        get_api :show_by_query, query_id: query.id
        expect(response.status).to eq(401)
      end

    end

    context "with an authenticated user" do

      let(:user) { Fabricate(:user) }

      before(:each) do
        sign_in user
      end

      it "complains on unknown resource" do
        get_api :show_by_query, query_id: "not_a_query"
        expect(response.status).to eq(404)
        expect(jsonapi_error).to eq("not found")
      end

      it "complains on invalid parameter" do
        get_api :show_by_query, query_id: [1,2,"not_an_id"]
        expect(response.status).to eq(400)
        expect(jsonapi_error).to eq("invalid parameters")
      end

      it "complains when not ready" do
        unfinished_query = Fabricate(:created_query)
        get_api :show_by_query, query_id: unfinished_query.id
        expect(response.status).to eq(409)
        expect(jsonapi_error).to eq("conflict")
      end

      it "fetches a query result body" do
        get_api :show_by_query, query_id: query.id, q_offset: 0, q_limit: 10
        expect(response.status).to eq(200)
        expect(jsonapi_meta 'offset').to eq(0)
        expect(jsonapi_meta 'limit').to eq(10)
        expect(jsonapi_meta 'count').to eq(4)
        expect(jsonapi_type).to eq('body')
        expect(jsonapi_id).to eq(query.id)
        expect(jsonapi_data).to reside_at(v2_query_result_body_url(query.id))
        expect(jsonapi_attr 'tuples').to eq([["MAD"], ["NCE"], ["BOS"], ["MUC"]])

        expect(jsonapi_rel 'relation').to \
          relate_to(v2_query_result_url(query.id))
      end
    end
  end

  context "on a relation" do

    before(:each) { mock_schemas }

    let!(:table) { Fabricate(:table) }

    context "with an authenticated user" do

      let(:user) { Fabricate(:user) }

      before(:each) do
        sign_in user
      end

      it "complains on unknown resource" do
        get_api :show_by_relation, relation_id: "not_a_relation"
        expect(response.status).to eq(404)
        expect(jsonapi_error).to eq("not found")
      end

      it "complains on invalid parameter" do
        get_api :show_by_relation, relation_id: [1,2,"not_an_id"]
        expect(response.status).to eq(400)
        expect(jsonapi_error).to eq("invalid parameters")
      end

      it "fetches a relation body" do
        pending("Body of non-query relation not implemented")
        get_api :show_by_relation, relation_id: table.id, q_offset: 0, q_limit: 10
        expect(response.status).to eq(200)
        expect(jsonapi_meta 'offset').to eq(0)
        expect(jsonapi_meta 'limit').to eq(10)
        expect(jsonapi_meta 'count').to eq(4)
        expect(jsonapi_type).to eq('body')
        expect(jsonapi_id).to eq(table.id)
        expect(jsonapi_data).to reside_at(v2_relation_body_url(table.id))
        expect(jsonapi_attr 'tuples').to eq([["MAD"], ["NCE"], ["BOS"], ["MUC"]])

        expect(jsonapi_rel 'relation').to \
          relate_to(v2_relation_url(table.id))
      end
    end
  end
end
