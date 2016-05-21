# encoding: utf-8
require 'rspec/expectations'
require 'jsonpath'

module ApiHelper
  extend RSpec::Matchers::DSL

  def first_json_at(path)
    JsonPath.on(response.body, path).first
  end

  def jsonapi_data
    JsonPath.on(response.body, '$.data').first
  end

  def jsonapi_type
    JsonPath.on(response.body, '$.data.type').first
  end

  def jsonapi_id
    JsonPath.on(response.body, '$.data.id').first
  end

  def jsonapi_attr(a)
    JsonPath.on(response.body, "$.data.attributes.#{a}").first
  end

  def jsonapi_rel(rel)
    JsonPath.on(response.body, "$.data.relationships.#{rel}").first
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
end

RSpec.configure do |c|
  c.include ApiHelper
end
