# encoding: utf-8
require 'jsonpath'

module JsonHelper
  def expect_json(document, expectations)
    expectations.each do |path, match|
      expect(JsonPath.on(document, path).first).to match
    end
  end
end

RSpec.configure do |c|
  c.include JsonHelper
end
