# frozen_string_literal: true

require 'tls/ping'

RSpec.describe TLS::Ping do
  describe '#succeeded?' do
    shared_examples 'a verified connection' do
      it 'has succeded' do
        expect(connection).to be_succeeded
      end
    end

    shared_examples 'an unverified connection' do
      it 'has failed' do
        expect(connection).not_to be_succeeded
      end
    end

    context 'with a valid TLS connection' do
      let(:connection) { described_class.new('example.com', 443) }

      it_behaves_like 'a verified connection'
    end

    context 'with an invalid TLS connection' do
      let(:connection) { described_class.new('example.com', 80) }

      it_behaves_like 'an unverified connection'
    end

    context 'with a valid STARTTLS connection' do
      let(:connection) { described_class.new('smtp.gmail.com', 25, starttls: true) }

      it_behaves_like 'a verified connection'
    end

    context 'with an invalid STARTTLS connection' do
      let(:connection) { described_class.new('smtp.gmail.com', 465, starttls: true) }

      it_behaves_like 'an unverified connection'
    end

    context 'with a expired certificate' do
      let(:connection) { described_class.new('expired.badssl.com', 443) }

      it_behaves_like 'an unverified connection'
    end

    context 'with missing issuer certificate' do
      let(:connection) { described_class.new('missing.badssl.com', 443) }

      it_behaves_like 'an unverified connection'
    end
  end

  describe '#succeeded!' do
    context 'with a valid TLS connection' do
      it 'does not raise an error' do
        expect { described_class.new('example.com', 443).succeeded! }.not_to raise_error
      end
    end

    context 'with an invalid TLS connection' do
      it 'raises an error' do
        expect { described_class.new('example.com', 80).succeeded! }.to raise_error(StandardError)
      end
    end
  end
end
