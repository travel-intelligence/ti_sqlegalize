# encoding: utf-8
require 'rspec/expectations'
require 'jsonpath'

module ApiHelper
  extend RSpec::Matchers::DSL

  def first_json_at(path)
    JsonPath.on(response.body, path).first
  end

  def jsonapi_root
    JsonPath.on(response.body, "$").first
  end

  def jsonapi_meta(a)
    JsonPath.on(response.body, "$.meta.#{a}").first
  end

  def jsonapi_error
    JsonPath.on(response.body, '$.errors[0].code').first
  end

  def jsonapi_data
    JsonPath.on(response.body, '$.data').first
  end

  def jsonapi_type(root=nil)
    JsonPath.on(root || jsonapi_data, '$.type').first
  end

  def jsonapi_id(root=nil)
    JsonPath.on(root || jsonapi_data, '$.id').first
  end

  def jsonapi_attr(a, root=nil)
    JsonPath.on(root || jsonapi_data, "$.attributes.#{a}").first
  end

  def jsonapi_rel(rel, root=nil)
    JsonPath.on(root || jsonapi_data, "$.relationships.#{rel}").first
  end

  def jsonapi_inc(type, id)
    JsonPath.on(response.body, "$.included").first.find do |inc|
      inc['type'] == type && inc['id'] == id
    end
  end

  def get_api(action, options = {})
    get action, options.merge(format: :jsonapi)
  end

  def post_api(action, options = {})
    post action, options.merge(format: :jsonapi)
  end

  matcher :relate_to do |expected|
    match do |actual|
      actual && \
      actual['links'] && \
      actual['links']['related'] == expected
    end
  end

  matcher :reside_at do |expected|
    match do |actual|
      actual && \
      actual['links'] && \
      actual['links']['self'] == expected
    end
  end

  matcher :be_identified_by do |expected|
    type, id = expected.to_a.first
    match do |actual|
      actual && \
      actual['data'] && \
      actual['data']['type'] == type && \
      actual['data']['id'] == id
    end
  end
end

RSpec.configure do |c|
  c.include ApiHelper
end
