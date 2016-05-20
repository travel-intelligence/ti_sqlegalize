# encoding: utf-8
require 'ti_rails_auth/spec_helper'

RSpec.configure do |config|
  config.include TiRailsAuth::SpecHelper, type: :controller
end
