# encoding: utf-8
require 'rails_helper'

describe "entry" do
  it "routes to entry point" do
    expect(get: "/v2/entry").to route_to(
      controller: "ti_sqlegalize/v2/entries",
      action: "show"
    )
  end

  it "routes to queries" do
    expect(post: "/v2/queries").to route_to(
      controller: "ti_sqlegalize/v2/queries",
      action: "create"
    )
  end

  it "routes to query" do
    expect(get: "/v2/queries/42").to route_to(
      controller: "ti_sqlegalize/v2/queries",
      action: "show",
      id: "42"
    )
  end

  it "routes to query result" do
    expect(get: "/v2/queries/42/result").to route_to(
      controller: "ti_sqlegalize/v2/relations",
      action: "show",
      query_id: "42"
    )
  end

  it "routes to query result heading" do
    expect(get: "/v2/queries/42/result/heading/city").to route_to(
      controller: "ti_sqlegalize/v2/headings",
      action: "show",
      query_id: "42",
      attr_id: "city"
    )
  end

  it "routes to query result body" do
    expect(get: "/v2/queries/42/result/body").to route_to(
      controller: "ti_sqlegalize/v2/bodies",
      action: "show",
      query_id: "42"
    )
  end

  it "routes to schemas" do
    expect(get: "/v2/schemas").to route_to(
      controller: "ti_sqlegalize/v2/schemas",
      action: "index"
    )
  end

  it "routes to domains" do
    expect(get: "/v2/domains/42").to route_to(
      controller: "ti_sqlegalize/v2/domains",
      action: "show",
      id: "42"
    )
  end

  it "routes to domain relations" do
    expect(get: "/v2/domains/42/relations").to route_to(
      controller: "ti_sqlegalize/v2/domains",
      action: "show_relations",
      domain_id: "42"
    )
  end
end
