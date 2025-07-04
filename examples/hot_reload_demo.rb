#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# Hot Reload Demo - Demonstrates Milktea::Loader with hot reloading
#
# This example shows how to configure Milktea for development with hot reloading.
# Unlike the basic examples, this one uses the optional Loader system to enable
# automatic code reloading when files change.
#
# To test hot reloading:
# 1. Run this file: ruby examples/hot_reload_demo.rb
# 2. In another terminal, edit files in examples/hot_reload_demo/models/
# 3. Save the files and see changes reflected immediately!
#
# Features demonstrated:
# - Custom configuration with Loader
# - Hot reloading setup
# - Modular component structure
# - Graceful degradation when Listen gem is unavailable

puts "=== Milktea Hot Reload Demo ==="
puts ""
puts "This demo shows hot reloading in action!"
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
config = Milktea.configure do |c|
  # Point to our demo components directory
  c.app_dir = "examples/hot_reload_demo/models"

  # Enable hot reloading explicitly
  c.hot_reloading = true
end

# Create independent loader with config
# This enables both autoloading and hot reloading
loader = Milktea::Loader.new(config)
loader.start # Automatically enables hot_reload if config.hot_reloading?

# Models will be automatically loaded by the Loader
# No need to manually require them
require_relative "hot_reload_demo/models/status_model"
require_relative "hot_reload_demo/models/demo_model"

# Create and run the program with hot reloading enabled
model = DemoModel.new
program = Milktea::Program.new(model, config: config)

puts "Hot reload demo starting..."
puts "Edit files in hot_reload_demo/models/ to see changes instantly!"
puts ""

begin
  program.run
rescue Interrupt
  puts "\nDemo ended. Thanks for trying hot reloading!"
end
