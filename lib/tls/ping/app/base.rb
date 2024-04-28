# frozen_string_literal: true

require 'clamp'
require 'pastel'
require 'tty-pager'

require_relative '../../ping'

module TLS
  class Ping
    module App
      class BaseCommand < Clamp::Command
        option ['-m', '--man'], :flag, 'show manpage' do # rubocop:disable Metrics/BlockLength
          manpage = <<~MANPAGE
            Name:
                tls-ping - TLS ping host and port

            #{help}
            Description:
                tls-ping connects to a given host and port and validates the
                TLS connection and certificate.

                tls-ping prompts an informational message and exits with one of
                following status code.

                Status codes:
                  0 - ping succeeded
                  1 - ping failed
                  255 - unknown error

            Examples:
                $ tls-ping badssl.com 443
                > badssl.com:443
                   [ OK ] /CN=*.badssl.com

                $ tls-ping badssl.com 80
                > badsll.com:80
                   [ FAIL ] Wrong version number

                $ tls-ping self-signed.badssl.com 443
                > self-signed.badssl.com:443
                   [ FAIL ] Certificate verify failed (self-signed certificate)

                $ tls-ping badssl.com 22
                > badssl.com:22
                   [ UNKNOWN ]

                $ tls-ping --starttls smtp.gmail.com 25
                > smtp.gmail.com:25
                   [ OK ] /CN=smtp.gmail.com

            Authors:
                Tobias Schäfer <github@blackox.org>

            Copyright and License
                This software is copyright (c) 2024 by Tobias Schäfer.

                This package is free software; you can redistribute it and/or
                modify it under the terms of the "GPLv3.0 License".
          MANPAGE
          TTY::Pager.page(manpage)

          exit 0
        end

        option ['-v', '--version'], :flag, 'show version' do
          puts "tls-ping #{TLS::Ping::VERSION} - All your certificate are belong to us!"
          exit(0)
        end
      end
    end
  end
end
