# frozen_string_literal: true

require_relative 'tls/ping'

# :nodoc:
module TLS
  class << self
    def ping(...)
      TLS::Ping.new(...).succeeded!
    end
  end
end
