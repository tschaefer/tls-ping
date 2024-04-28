# frozen_string_literal: true

ROOT = "#{File.dirname(__FILE__)}/..".freeze

def silent
  original_stdout = $stdout.clone
  original_stderr = $stderr.clone
  $stderr.reopen File.new(File::NULL, 'w')
  $stdout.reopen File.new(File::NULL, 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end

def reload!(print: true)
  puts 'Reloading...' if print
  reload_dirs = %w[lib]
  reload_dirs.each do |dir|
    Dir.glob("#{ROOT}/#{dir}/**/*.rb").each { |f| silent { load(f) } }
  end

  true
end

desc 'Start a console session with TLS::Ping loaded'
task :console do
  require 'pry'
  require 'pry-doc'
  require 'pry-theme'
  require 'tls'
  require 'tls/ping'

  ARGV.clear

  Pry.start
end
