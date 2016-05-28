# encoding: utf-8
module TiSqlegalize
  class Engine < ::Rails::Engine
    isolate_namespace TiSqlegalize

    config.ti_sqlegalize = ActiveSupport::OrderedOptions.new
    config.ti_sqlegalize.max_body_limit = 10000
  end

  class Config
    def self.max_body_limit
      Rails.application.config.ti_sqlegalize.max_body_limit
    end
  end
end
