# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::HeadingsController do

  before(:each) do
    mock_domains
  end

  context "on a query" do

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

      it "complains on unknown attribute" do
        get_api :show_by_query, query_id: query.id, attr_id: 'not_an_attribute'
        expect(response.status).to eq(404)
        expect(jsonapi_error).to eq("not found")
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

  context "on a relation" do

    before(:each) do
      mock_schemas
    end

    let!(:table) { Fabricate(:table) }

    context "with an authenticated user" do

      let(:user) { Fabricate(:user) }

      before(:each) do
        sign_in user
      end

      it "complains on unknown resource" do
        get_api :show_by_relation, relation_id: "not_a_relation", attr_id: 'a'
        expect(response.status).to eq(404)
        expect(jsonapi_error).to eq("not found")
      end

      it "complains on invalid parameter" do
        get_api :show_by_relation, relation_id: [1,2,"not_an_id"], attr_id: 'a'
        expect(response.status).to eq(400)
        expect(jsonapi_error).to eq("invalid parameters")
      end

      it "complains on unknown attribute" do
        get_api :show_by_relation, relation_id: table.id, attr_id: 'not_an_attribute'
        expect(response.status).to eq(404)
        expect(jsonapi_error).to eq("not found")
      end

      it "fetches a relation attribute" do
        get_api :show_by_relation, relation_id: table.id, attr_id: 'BOARD_CITY'
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

      context "with a user without schema access" do

        let(:user) { Fabricate(:user_hr) }

        it "compains for unknown relation" do
          get_api :show_by_relation, relation_id: table.id, attr_id: 'BOARD_CITY'
          expect(response.status).to eq(404)
          expect(jsonapi_error).to eq("not found")
        end
      end
    end
  end
end
