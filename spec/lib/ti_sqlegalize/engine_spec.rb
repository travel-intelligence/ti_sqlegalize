# encoding: utf-8
require 'rails_helper'

RSpec.describe TiSqlegalize::Engine do

  it "accepts configuration" do
    expect(TiSqlegalize::Config.max_body_limit).to eq(10000)
    expect(TiSqlegalize::Config.auth_mixin.to_s).to eq("TestApp::TestAuthMixin")
    expect(TiSqlegalize::Config.database.class.to_s).to eq("TestApp::TestDatabase")
    expect(TiSqlegalize::Config.validator.class.to_s).to eq("TestApp::TestValidator")
    expect(TiSqlegalize::Config.domains.class.to_s).to eq("TestApp::TestDomains")
    expect(TiSqlegalize::Config.schemas.class.to_s).to eq("TestApp::TestSchemas")
  end
end
