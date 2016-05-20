# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::EntriesController do

  context "without and authenticated user" do

    it "requires authentication" do
      get_api :show
      expect(response.status).to eq(401)
    end

  end

  context "with an authenticated user" do

    let!(:user) { Fabricate(:user) }
    before(:each) { sign_in user }

    it "represents the entry point" do
      get_api :show
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('entry')
      expect(jsonapi_id).not_to be_nil
      expect(jsonapi_rel 'queries').to relate_to(v2_queries_url)
      expect(jsonapi_rel 'schemas').to relate_to(v2_schemas_url)
      expect(jsonapi_data).to reside_at(v2_entry_url)
    end
  end
end
