# encoding: utf-8

module AuthHelper
  def sign_in(user)
    allow(controller).to receive(:authenticate).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :controller
end
