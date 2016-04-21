# encoding: utf-8
require 'rails_helper'

RSpec.describe TiSqlegalize::Query, :type => :model do

  before(:each) { Resque.redis = MockRedis.new }

  let!(:queue) { Resque.queue_from_class(TiSqlegalize::Query) }

  let!(:ttl) { 3600 }

  let!(:query) { TiSqlegalize::Query.new('select 1', quota: 100, ttl: ttl) }

  let!(:schema) { ['x','y','z'] }

  let!(:row) { ['a','b','c'] }

  let!(:rows) { [row] }

  let!(:cursor) do
    c = rows.dup
    c.define_singleton_method(:close) {}
    c.define_singleton_method(:open?) { true }
    # Ruby VM crash when referring to schema in singleton method definition
    s = schema
    c.define_singleton_method(:schema) { s }
    c
  end

  it 'creates new queries' do
    query.create!
    expect(query.id).not_to be_nil
    expect(query.status).to eq(:created)
    expect(Resque.redis.keys.length).to eq(2)
  end

  it 'does not save nonexistent queries' do
    query.status = :finished
    query.save!
    expect(query.id).to be_nil
    expect(Resque.redis.keys.length).to eq(0)
  end

  it 'updates created queries' do
    query.create!
    query.status = :finished
    query.save!

    q = TiSqlegalize::Query.find(query.id)
    expect(q.status).to eq(:finished)
  end

  it 'appends rows' do
    query.create!
    query << rows

    q = TiSqlegalize::Query.find(query.id)
    expect(q[0, 10]).to eq(rows)
  end

  it 'performs statement' do
    query.create!

    expect(cursor).to receive(:close)
    expect(query).to receive(:execute).with(query.statement).and_return(cursor)
    expect(TiSqlegalize::Query).to receive(:find).with(query.id).and_return(query)

    TiSqlegalize::Query.perform(query.id)

    expect(query[0, 10]).to eq([row])
    expect(query.schema).to eq(schema)
  end

  context 'with quota' do

    let!(:quota) { 5 }
    let!(:query) { TiSqlegalize::Query.new('select 1', quota: quota) }
    let!(:rows) { [row] * 7 }

    it 'enforces quota' do
      query.create!

      expect(query).to receive(:execute).with(query.statement).and_return(cursor)

      query.run

      q = TiSqlegalize::Query.find(query.id)
      expect(q[0, 10]).to eq(rows.take quota)
      expect(q.count).to eq(quota)
      expect(q.quota).to eq(quota)
    end
  end

  it 'expires queries' do
    query.create!

    expect(query).to receive(:execute).with(query.statement).and_return(cursor)

    query.run

    expect(query.time_left).to be_within(60).of(ttl)

    query.expire_after -1

    q = TiSqlegalize::Query.find(query.id)
    expect(q.status).to eq(:finished)
    expect(q[0, 10]).to be_empty
  end

  context 'with database errors' do

    let!(:database_error) { "Database error" }

    it 'keeps error message and status with the query' do
      query.create!

      expect(query).to receive(:execute) { fail database_error }

      query.run

      q = TiSqlegalize::Query.find(query.id)
      expect(q.status).to eq(:error)
      expect(q.message).to eq(database_error)
    end
  end
end
