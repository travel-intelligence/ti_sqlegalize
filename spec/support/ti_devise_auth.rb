require 'ti_devise_auth/spec_helper'

RSpec.configure do |config|
  config.include TiDeviseAuth::SpecHelper, type: :controller
end
