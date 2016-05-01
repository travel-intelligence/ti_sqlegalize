require 'cztop'

module TiSqlegalize
  class ZMQSocket
    def initialize(endpoint)
      @socket = CZTop::Socket::REQ.new
      @socket.options.rcvtimeo = Rails.env.production? ? 1000 : 5000
      @socket.connect(endpoint)
    end

    def <<(msg)
      @socket << msg
    end

    def receive
      @socket.receive
    end
  end
end
