require 'mock_redis'
require 'resque'

module ResqueHelper
  def perform_all(queue)
    while (job = Resque::Job.reserve(queue)) do
      job.perform
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    Resque.redis = MockRedis.new
  end
  config.include ResqueHelper
end
