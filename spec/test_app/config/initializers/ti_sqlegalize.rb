
module TestApp
  module TestAuthMixin
    def authenticate
    end

    def current_user
    end
  end

  class TestDatabase
  end

  class TestValidator
  end

  class TestDomains
  end

  class TestSchemas
  end
end

Rails.application.configure do

  config.ti_sqlegalize.auth_mixin = '::TestApp::TestAuthMixin'

  config.ti_sqlegalize.database = -> do
    TestApp::TestDatabase.new
  end

  config.ti_sqlegalize.validator = -> do
    TestApp::TestValidator.new
  end

  config.ti_sqlegalize.domains = -> do
    TestApp::TestDomains.new
  end

  config.ti_sqlegalize.schemas = -> do
    TestApp::TestSchemas.new
  end
end
