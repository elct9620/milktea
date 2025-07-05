#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# Hot Reload Demo using Milktea::Application - Simplified setup
#
# This example shows how to use Milktea::Application for easier setup.
# The Application class encapsulates Loader and Program configuration.
#
# To test hot reloading:
# 1. Run this file: ruby examples/hot_reload_demo.rb
# 2. In another terminal, edit files in examples/hot_reload_demo/models/
# 3. Save the files and see changes reflected immediately!
#
# Features demonstrated:
# - Simplified Application setup
# - Automatic Loader and Program configuration
# - Hot reloading with minimal boilerplate
# - Clean Architecture with DDD principles

puts "=== Milktea Application Hot Reload Demo ==="
puts ""
puts "This demo shows the new Application class in action!"
puts "Try editing files in hot_reload_demo/models/ while this runs."
puts ""

# Check if Listen gem is available for optimal experience
begin
  gem "listen"
  puts "✓ Listen gem detected - hot reloading will work!"
rescue Gem::LoadError
  puts "⚠ Listen gem not found - basic autoloading only"
  puts "  Install with: gem install listen"
end

puts ""
puts "Starting demo... (press any key to continue)"
gets

# Configure Milktea for hot reloading
Milktea.configure do |c|
  # Point to our demo components directory
  c.app_dir = "examples/hot_reload_demo/models"

  # Enable hot reloading explicitly
  c.hot_reloading = true
end

# Define Application class
class HotReloadDemo < Milktea::Application
  root "DemoModel"
end

puts "Hot reload demo starting..."
puts "Edit files in hot_reload_demo/models/ to see changes instantly!"
puts ""

begin
  HotReloadDemo.new.run
rescue Interrupt
  puts "\nDemo ended. Thanks for trying the new Application class!"
end
