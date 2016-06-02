# encoding: utf-8
# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::SchemasController do

  before(:each) { mock_schemas }

  let!(:schema) { Fabricate(:schema) }

  context "without and authenticated user" do

    it "requires authentication" do
      get_api :index
      expect(response.status).to eq(401)
    end

    it "requires authentication" do
      get_api :show, id: schema.id
      expect(response.status).to eq(401)
    end

  end

  context "with an authenticated user" do

    let(:user) { Fabricate(:user) }

    before(:each) { sign_in user }

    it "complains on unknown resource" do
      get_api :show, id: "not_a_schema"
      expect(response.status).to eq(404)
      expect(jsonapi_error).to eq("not found")
    end

    it "complains on invalid parameter" do
      get_api :show, id: [1,2,"not_an_id"]
      expect(response.status).to eq(400)
      expect(jsonapi_error).to eq("invalid parameters")
    end

    it "represents a schema" do
      get_api :show, id: schema.id
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('schema')
      expect(jsonapi_id).to eq(schema.id)
      expect(jsonapi_data).to \
        reside_at(v2_schema_url(schema.id))
      expect(jsonapi_attr 'name').to eq('MARKET')
      expect(jsonapi_attr 'description').to eq('Market schema')
      expect(jsonapi_rel 'relations').to \
        relate_to(v2_schema_relations_url(schema.id))
    end

    it "represents a collection of schemas" do
      get_api :index
      expect(response.status).to eq(200)
      expect(jsonapi_data.size).to eq(2)

      s = jsonapi_data.find { |d| d['id'] == schema.id }
      expect(jsonapi_type s).to eq('schema')
      expect(jsonapi_id s).to eq(schema.id)
      expect(s).to \
        reside_at(v2_schema_url(schema.id))
      expect(jsonapi_attr 'name', s).to eq('MARKET')
      expect(jsonapi_attr 'description', s).to eq('Market schema')
      expect(jsonapi_rel 'relations', s).to \
        relate_to(v2_schema_relations_url(schema.id))
    end
  end
end
