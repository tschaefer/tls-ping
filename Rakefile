# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

FileList['tasks/**/*.rake'].each { |f| import(f) }

RSpec::Core::RakeTask.new(:rspec)
RuboCop::RakeTask.new

desc "Run tasks 'rubocop' by default."
task default: %w[rubocop]
