# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'tls/ping'

Gem::Specification.new do |spec|
  spec.name                  = 'tls-ping'
  spec.version               = TLS::Ping::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 3.3.0'
  spec.authors               = ['Tobias Schäfer']
  spec.email                 = ['github@blackox.org']

  spec.summary     = 'Ping TLS host and port.'
  spec.description = <<~DESC
    #{spec.summary}
  DESC
  spec.homepage    = 'https://github.com/tschaefer/tls-ping'
  spec.license     = 'MIT'

  spec.files         = Dir['lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = ['tls-ping']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri']       = 'https://github.com/tschaefer/tls-ping'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/tschaefer/tls-ping/issues'

  spec.post_install_message = 'All your certificate are belong to us!'

  spec.add_dependency 'clamp', '~> 1.3.2'
  spec.add_dependency 'pastel', '~> 0.8.0'
  spec.add_dependency 'tty-pager', '~> 0.14.0'
end
