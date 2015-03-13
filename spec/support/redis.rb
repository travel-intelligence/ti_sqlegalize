require 'mock_redis'
require 'resque'

RSpec.configure do |config|
  config.before(:suite) do
    Resque.redis = MockRedis.new
  end
end
