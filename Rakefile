begin
  require "bundler/gem_tasks"
rescue LoadError
  # Not everybody needs bundler tasks.
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new('yard:doc') do |task|
    task.options = ['--no-stats']
  end

  task 'yard:stats' do
    YARD::CLI::Stats.run('--list-undoc')
  end

  task :yard => ['yard:doc', 'yard:stats']
rescue LoadError
  puts "WARN: YARD not available. You may install documentation dependencies via bundler."
end

desc "Run an interactive console with Ruhue loaded"
task :console do
  exec "irb", "-Ilib", "-rruhue"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  spec.ruby_opts = %w[-W]
end

task :default => :spec
