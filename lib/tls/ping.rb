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
      socket = tcp_socket
      starttls(socket) if @starttls
      tls_socket = tls_socket(socket)
    rescue StandardError => e
      @error = e
    ensure
      @peer_cert = tls_socket&.peer_cert || tls_socket&.peer_cert_chain&.first
      tls_socket&.close
      socket&.close
    end

    def socket
      addr_info = Socket.getaddrinfo(@host, nil, nil, Socket::SOCK_STREAM)
      address_family = addr_info[0][4]

      socket = Socket.new(address_family, Socket::SOCK_STREAM, 0)
      sockaddr = Socket.sockaddr_in(@port, addr_info[0][3])

      begin
        socket.connect_nonblock(sockaddr)
      rescue IO::WaitWritable
        if socket.wait_writable(@timeout)
          begin
            socket.connect_nonblock(sockaddr)
          rescue Errno::EISCONN
            # connection established
          rescue StandardError => e
            socket.close
            raise e
          end
        else
          socket.close
          raise Timeout::Error, 'Execution expired'
        end
      end

      socket
    end

    def tcp_socket
      socket = socket()

      tcp_socket = TCPSocket.for_fd(socket.fileno)
      tcp_socket.autoclose = true
      tcp_socket.timeout = @timeout

      tcp_socket
    end

    def tls_socket(socket)
      tls_socket = OpenSSL::SSL::SSLSocket.new(socket, tls_ctx)
      tls_socket.hostname = @host
      tls_socket.sync_close = true
      tls_socket.connect

      tls_socket
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
      Timeout.timeout(@timeout) do
        socket.readpartial(4096)
        socket.write("EHLO tls.ping\r\n")
        socket.readpartial(4096)

        ['STARTTLS', 'AUTH TLS', 'AUTH SSL', 'a001 STARTTLS'].each do |command|
          socket.write("#{command}\r\n")
          response = socket.readpartial(4096)
          break if response.start_with?(/2\d\d /)
          break if response.start_with?('a001 OK')
        end
      end
    end
  end
end
