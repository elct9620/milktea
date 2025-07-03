# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Milktea is a Terminal User Interface (TUI) framework for Ruby, inspired by the Bubble Tea framework for Go. It's designed to help developers create interactive command-line applications with rich terminal interfaces.

## Development Commands

### Testing
- `bundle exec rake spec` - Run all RSpec tests
- `bundle exec rspec spec/path/to/specific_spec.rb` - Run a specific test file
- `bundle exec rspec spec/path/to/specific_spec.rb:42` - Run a specific test at line 42

### Code Quality
- `bundle exec rake rubocop` - Run RuboCop linting
- `bundle exec rake rubocop:autocorrect` - Auto-fix safe violations
- `bundle exec rake` - Run default task (specs + RuboCop)

### Building and Installation
- `bundle exec rake build` - Build gem into pkg/ directory
- `bundle exec rake install:local` - Install gem locally for testing

### Development Tools
- `bin/console` - Interactive Ruby console with gem loaded

## Architecture

This project follows Clean Architecture and Domain-Driven Design (DDD) principles. The codebase structure:

- `/lib/milktea.rb` - Main module entry point with Zeitwerk autoloading
- `/lib/milktea/model.rb` - Base Model class for Elm Architecture components
- `/lib/milktea/runtime.rb` - Message processing and execution state management
- `/lib/milktea/program.rb` - Main TUI program with event loop
- `/lib/milktea/message.rb` - Message definitions for events
- Uses TTY gems for terminal interaction (tty-box, tty-cursor, tty-reader, tty-screen)
- Event handling through the `timers` gem

### Core Components

- **Model**: Base class implementing Elm Architecture with immutable state
- **Runtime**: Manages message queue and execution state with dependency injection support
- **Program**: Handles terminal setup, rendering, and main event loop
- **Message**: Event system using Ruby's Data.define for immutable messages

## Testing Approach

- RSpec 3.x for unit testing
- Test files mirror the lib structure in the spec/ directory
- Monkey patching is disabled for cleaner tests
- Run individual tests with line numbers for focused development

### RSpec Style Guide

Follow these conventions when writing RSpec tests:

1. **Use `subject` for test targets**:
   ```ruby
   subject(:program) { described_class.new }
   subject(:new_model) { model.with(count: 5) }
   ```

2. **Use `let` for test dependencies and lazy evaluation**:
   ```ruby
   let(:output) { StringIO.new }
   let(:new_model) { result.first }
   let(:message) { result.last }
   ```

3. **Use `context` + `before` for shared setup**:
   ```ruby
   context "with increment message" do
     subject(:result) { model.update(:increment) }
     
     it { expect(new_model.state[:count]).to eq(1) }
   end
   ```

4. **Prefer one-line syntax for simple expectations**:
   ```ruby
   it { expect(output.string).to include("Hello from Milktea!") }
   it { is_expected.to be_running }
   ```

5. **Use `is_expected` when testing the subject directly**:
   ```ruby
   it { is_expected.to be_running }  # Preferred
   # vs
   it { expect(subject).to be_running }  # Avoid
   ```

6. **Use `.to change()` for testing immutability**:
   ```ruby
   it { expect { model.update(:increment) }.not_to change(model, :state) }
   it { expect { model.with(count: 5) }.not_to change(model, :state) }
   ```

7. **Each `it` block should have only one expectation**:
   ```ruby
   # Good
   it { expect(new_model).not_to be(model) }
   it { expect(new_model.state[:count]).to eq(5) }
   
   # Avoid
   it "creates new instance with updated state" do
     new_model = model.with(count: 5)
     expect(new_model).not_to be(model)
     expect(new_model.state[:count]).to eq(5)
   end
   ```

8. **Use `context` to group related test scenarios**:
   ```ruby
   context "when merging with existing state" do
     let(:model_with_data) { test_model_class.new(count: 1, name: "test") }
     subject(:merged_model) { model_with_data.with(count: 2) }
     
     it { expect(merged_model.state[:count]).to eq(2) }
     it { expect(merged_model.state[:name]).to eq("test") }
   end
   ```

9. **Use descriptive blocks when one-liners aren't sufficient**:
   ```ruby
   it "is expected to handle complex scenarios" do
     # Multiple expectations or setup required
   end
   ```

## Important Notes

- Ruby version requirement: >= 3.1.0
- Uses conventional commits format in English
- The gemspec uses git to determine which files to include in the gem
- Currently in early development (v0.1.0) with core architecture implemented
- Runtime-based architecture allows dependency injection for testing and customization
- Program uses dependency injection pattern: `Program.new(model, runtime: custom_runtime)`

## Repository Management

- Keep ARCHITECTURE.md updated when we change anything