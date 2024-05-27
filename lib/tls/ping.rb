# frozen_string_literal: true

require 'tls/certificate'
require 'tls/socket'

module TLS
  class Ping
    VERSION = '0.1.0'

    attr_reader :error, :peer_cert

    def initialize(host, port, starttls: false, timeout: 5)
      @host = host
      @port = port
      @starttls = starttls
      @timeout = timeout

      execute
    end

    def succeeded?
      @error.nil?
    end

    def succeeded!
      raise @error if @error
    end

    private

    def execute
      socket = TLS::Socket.new(@host, @port, starttls: @starttls, timeout: @timeout)
      socket.connect
      @peer_cert = socket.peer_cert
      TLS::Certificate.new(@peer_cert, @host).valid!
    rescue StandardError => e
      @error = e
    ensure
      socket&.close
    end
  end
end
