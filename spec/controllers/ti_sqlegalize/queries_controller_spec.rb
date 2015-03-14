# encoding: utf-8
require 'rails_helper'

RSpec.describe TiSqlegalize::QueriesController, :type => :controller do

  before(:each) { Resque.redis = MockRedis.new }

  let!(:queue) { Resque.queue_from_class(TiSqlegalize::Query) }

  context "with an authenticated user" do

    let!(:user) { Fabricate(:user) }
    before(:each) { sign_in user }

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
      expect(Resque.size(queue)).to eq(0)
      rep = { queries: { sql: "select a from t1, (select b,c from d.t) t2" } }
      post_api :create, rep
      expect(response.status).to eq(201)
      expect(first_json_at '$.queries.tables').to eq(["d.t", "t1"])
    end

    context "with a query engine" do

      before(:each) do
        @results = ['a','b','c']
        allow(TiSqlegalize::Query).to receive(:execute).and_return(@results)
      end

      it "enqueue queries for processing" do
        expect(Resque.size(queue)).to eq(0)
        post_api :create, { queries: { sql: "select 1" } }
        expect(response.status).to eq(201)
        expect(Resque.size(queue)).to eq(1)

        query_id = first_json_at '$.queries.id'
        query_url = first_json_at '$.queries.href'
        expect(get: query_url).to route_to(
          controller: 'ti_sqlegalize/queries', action: 'show', id: query_id)

        get_api :show, id: query_id
        expect(response.status).to eq(200)
        expect(first_json_at '$.queries.status').to eq('created')

        job = Resque::Job.reserve(queue)
        job.perform

        get_api :show, id: query_id, offset: 0, limit: 100
        expect(response.status).to eq(200)
        expect(first_json_at '$.queries.status').to eq('finished')
        expect(first_json_at '$.queries.rows').to eq(@results)
        expect(first_json_at '$.queries.quota').to eq(100_000)
        expect(first_json_at '$.queries.count').to eq(@results.length)
      end
    end
  end

  context "without an authenticated user" do
    it 'returns an error without authentication' do
      rep = { queries: { sql: "select a from t1, (select b,c from d.t) t2" } }
      post_api :create, rep
      expect(response.status).to eq(401)
    end
  end
end
