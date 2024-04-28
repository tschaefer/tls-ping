# frozen_string_literal: true

require 'openssl'
require 'socket'
require 'timeout'

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
      socket = Timeout.timeout(@timeout) do
        socket = TCPSocket.new(@host, @port)
        socket.timeout = @timeout
        socket
      end

      starttls(socket) if @starttls

      tls_socket = OpenSSL::SSL::SSLSocket.new(socket, tls_ctx)
      tls_socket.hostname = @host
      tls_socket.connect
    rescue StandardError => e
      @error = e
    ensure
      @peer_cert = tls_socket&.peer_cert || tls_socket&.peer_cert_chain&.first
      tls_socket&.close
      socket&.close
    end

    def tls_ctx
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        store = OpenSSL::X509::Store.new
        store.set_default_paths

        ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
        ctx.cert_store = store
        ctx.timeout = @timeout
      end
    end

    def starttls(socket)
      return if !@starttls

      socket.gets
      socket.write("EHLO tls.ping\r\n")

      loop do
        break if socket.gets.start_with?('250 ')
      end

      socket.write("STARTTLS\r\n")
      socket.gets
    end
  end
end
