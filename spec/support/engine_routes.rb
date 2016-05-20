# encoding: utf-8
module SpecRoutes
  def self.included(base)
    base.routes { TiSqlegalize::Engine.routes }
  end 
end

RSpec.configure do |config|
  config.include SpecRoutes, type: :routing
  config.include SpecRoutes, type: :controller
end
