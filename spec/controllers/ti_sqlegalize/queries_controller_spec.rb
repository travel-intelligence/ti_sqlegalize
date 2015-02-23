# encoding: utf-8
require 'rails_helper'

RSpec.describe TiSqlegalize::QueriesController, :type => :controller do

  it "creates queries" do
    rep = { queries: { sql: "select * from t" } }
    post_api :create, rep
    expect(response.status).to eq(201)
    location = response.headers['Location']
    expect(location).not_to be_blank
    expect(first_json_at '$.queries.id').not_to be_nil
    expect(first_json_at '$.queries.href').to eq(location)
    expect(first_json_at '$.queries.sql').to eq(rep[:queries][:sql])
    expect(first_json_at '$.queries.tables').not_to be_empty
  end

  it "complains on missing query" do
    rep = { invalid: "input" }
    post_api :create, rep
    expect(response.status).to eq(400)
  end

  it "complains on invalid query" do
    rep = { queries: { sql: "this is not a valid SQL query" } }
    post_api :create, rep
    expect(response.status).to eq(400)
  end

  it "extract all tables from a valid query" do
    rep = { queries: { sql: "select a from t1, (select b,c from d.t) t2" } }
    post_api :create, rep
    expect(response.status).to eq(201)
    expect(first_json_at '$.queries.tables').to eq(["d.t", "t1"])
  end

  it "inspects queries" do
    pending("not implemented")
    get_api :show, id: 42
    expect(response.status).to eq(200)
  end
end
