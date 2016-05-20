# encoding: utf-8
require 'rails_helper'

describe "entry" do
  it "routes to entry point" do
    expect(:get => "/v2/entry").to route_to(
      :controller => "ti_sqlegalize/v2/entries",
      :action => "show"
    )
  end

  it "routes to queries" do
    expect(:post => "/v2/queries").to route_to(
      :controller => "ti_sqlegalize/v2/queries",
      :action => "create"
    )
  end

  it "routes to schemas" do
    expect(:get => "/v2/schemas").to route_to(
      :controller => "ti_sqlegalize/v2/schemas",
      :action => "index"
    )
  end
end
