# encoding: utf-8
require 'ti_sqlegalize/dummy_auth'

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

  class Config
    def self.max_body_limit
      Rails.application.config.ti_sqlegalize.max_body_limit
    end

    def self.auth_mixin
      if (mix = Rails.application.config.ti_sqlegalize.auth_mixin)
        const_get mix
      else
        TiSqlegalize::DummyAuth
      end
    end

    def self.database
      if (db = Rails.application.config.ti_sqlegalize.database)
        db.call
      else
        TiSqlegalize::DummyDatabase.new
      end
    end

    def self.validator
      if (val = Rails.application.config.ti_sqlegalize.validator)
        val.call
      else
        TiSqlegalize::SQLiterateValidator.new
      end
    end

    def self.domains
      if (dom = Rails.application.config.ti_sqlegalize.domains)
        dom.call
      else
        TiSqlegalize::DomainDirectory.new
      end
    end

    def self.schemas
      if (sch = Rails.application.config.ti_sqlegalize.schemas)
        sch.call
      else
        TiSqlegalize::SchemaDirectory.new
      end
    end
  end
end
