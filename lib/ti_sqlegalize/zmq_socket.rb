# encoding: utf-8
require 'cztop'

module TiSqlegalize
  class ZMQSocket
    def initialize(endpoint)
      @socket = CZTop::Socket::REQ.new
      @socket.options.rcvtimeo = Rails.env.production? ? 1000 : 5000
      @socket.connect(endpoint)
    end

    def response_for(msg)
      @socket << msg
      @socket.receive.pop
    end
  end
end
