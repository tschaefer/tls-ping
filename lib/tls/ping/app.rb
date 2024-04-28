# frozen_string_literal: true

require_relative 'app/base'
require_relative '../../tls'

module TLS
  class Ping
    module App
      class Command < TLS::Ping::App::BaseCommand
        parameter 'HOST', 'hostname to ping'
        parameter 'PORT', 'port to ping'
        option ['-s', '--starttls'], :flag, 'use STARTTLS'
        option ['-t', '--timeout'], 'SECONDS', 'timeout in seconds', default: 5
        option ['-q', '--quiet'], :flag, 'suppress output'

        PING_OK = 0
        PING_FAIL = 1
        PING_UNKNOWN = 255

        def execute
          header
          code, reason = action
          result(code, reason:)

          exit(code)
        end

        private

        def header
          return if quiet?

          puts "> #{host}:#{port}" if !quiet?
        end

        def action
          ping = TLS::Ping.new(
            host,
            port,
            starttls: starttls?,
            timeout: timeout.to_f
          )
          ping.succeeded!

          reason = ping.peer_cert.subject.to_s
          [PING_OK, reason]
        rescue OpenSSL::SSL::SSLError => e
          reason = e.message.split(': ').last.capitalize
          [PING_FAIL, reason]
        rescue StandardError
          [PING_UNKNOWN]
        end

        def result(code, reason: nil)
          return if quiet?

          status = {
            PING_OK => Pastel.new.green.bold('OK'),
            PING_FAIL => Pastel.new.red.bold('FAIL'),
            PING_UNKNOWN => Pastel.new.yellow.bold('UNKNOWN')
          }[code]

          info = "   [ #{status} ]"
          info += " #{reason}" if reason

          puts info
        end
      end
    end
  end
end
