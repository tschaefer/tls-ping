# frozen_string_literal: true

require 'openssl'
require 'resolv'

module TLS
  class Certificate
    def initialize(certificate, host)
      @certificate = certificate
      @host = host
    end

    def valid?
      begin
        name_valid!
      rescue StandardError
        return false
      end

      true
    end

    def valid!
      name_valid!
    end

    private

    def name_valid!
      return if common_name_valid?

      alternative_name_valid!
    end

    def common_name_valid?
      hosts = @certificate.subject.to_s.split('/').map { |key| key.sub('CN=', '') }
      name_match?(hosts)
    end

    def alternative_name_valid!
      san = @certificate.extensions.find { |ext| ext.oid == 'subjectAltName' }
      raise OpenSSL::SSL::SSLError, 'No alternative certificate subject names found' if !san

      pattern = @host.match?(Resolv::AddressRegex) ? 'IP Address:' : 'DNS:'
      hosts = san.value.split(', ').map { |key| key.sub(pattern, '') }
      return if name_match?(hosts)

      raise OpenSSL::SSL::SSLError, 'No alternative certificate subject name matches target host name'
    end

    def name_match?(hosts)
      return false if hosts.empty?

      hosts.any? do |host|
        @host == host || (host.include?('*') &&
          @host.match?(Regexp.new("^#{host.gsub('*', '.*')}$")))
      end
    end
  end
end
