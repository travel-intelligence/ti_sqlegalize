# encoding: utf-8
require 'jsonpath'

module ApiHelper
  def first_json_at(path)
    JsonPath.on(response.body, path).first
  end
  
  def get_api(action, options = {})
    get action, options.merge(format: :jsonapi)
  end

  def post_api(action, options = {})
    post action, options.merge(format: :jsonapi)
  end
end

RSpec.configure do |c|
  c.include ApiHelper
end
