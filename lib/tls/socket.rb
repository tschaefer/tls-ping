# frozen_string_literal: true

require 'openssl'
require 'socket'
require 'timeout'

module TLS
  class Socket
    attr_reader :raw, :secure

    def initialize(host, port, starttls: false, timeout: 5)
      @host = host
      @port = port
      @starttls = starttls
      @timeout = timeout
    end

    def open
      tcp_socket = tcp_socket(socket)
      start_tls(tcp_socket) if @starttls
      tls_socket = tls_socket(tcp_socket)

      @raw = tcp_socket
      @secure = tls_socket
    end

    def close
      @secure&.close if @secure&.closed? == false
      @raw&.close if @raw&.closed? == false

      @secure = nil
      @raw = nil
    end

    def peer_cert
      @secure&.peer_cert || @secure&.peer_cert_chain&.first
    end

    private

    def socket
      addr_info = ::Socket.getaddrinfo(@host, nil, nil, ::Socket::SOCK_STREAM)
      address_family = addr_info[0][4]

      socket = ::Socket.new(address_family, ::Socket::SOCK_STREAM, 0)
      sockaddr = ::Socket.sockaddr_in(@port, addr_info[0][3])

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

    def tcp_socket(socket)
      tcp_socket = TCPSocket.for_fd(socket.fileno)
      tcp_socket.autoclose = true
      tcp_socket.timeout = @timeout

      tcp_socket
    end

    def tls_socket(tcp_socket)
      tls_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, tls_context)
      tls_socket.hostname = @host
      tls_socket.sync_close = true
      tls_socket.connect

      tls_socket
    end

    def tls_context
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        store = OpenSSL::X509::Store.new
        store.set_default_paths

        ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
        ctx.cert_store = store
        ctx.timeout = @timeout
      end
    end

    def start_tls(tcp_socket)
      Timeout.timeout(@timeout) do
        tcp_socket.readpartial(4096)
        tcp_socket.write("EHLO tls.ping\r\n")
        tcp_socket.readpartial(4096)

        ['STARTTLS', 'AUTH TLS', 'AUTH SSL', 'a001 STARTTLS'].each do |command|
          tcp_socket.write("#{command}\r\n")
          data = tcp_socket.readpartial(4096)
          break if data.start_with?(/2\d\d /)
          break if data.start_with?('a001 OK')
        end
      end
    end
  end
end
