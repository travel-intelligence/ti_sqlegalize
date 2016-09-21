# encoding: utf-8

module TiSqlegalize
  class Engine < ::Rails::Engine
    isolate_namespace TiSqlegalize

    config.ti_sqlegalize = ActiveSupport::OrderedOptions.new
    config.ti_sqlegalize.max_body_limit = 10000
    config.ti_sqlegalize.auth_mixin = nil
    config.ti_sqlegalize.database = nil
    config.ti_sqlegalize.validator = nil
    config.ti_sqlegalize.domains = nil
    config.ti_sqlegalize.schemas = nil
  end
end
