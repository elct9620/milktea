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

1. **ALWAYS prefer one-line `it { ... }` syntax**:
   ```ruby
   # Preferred - Always use this when possible
   it { expect(model.state[:count]).to eq(0) }
   it { expect(model.state).to be_frozen }
   it { is_expected.to be_running }
   
   # Avoid - Multi-line blocks should be rare
   it "has expected state" do
     expect(model.state[:count]).to eq(0)
   end
   ```

2. **Use `subject` to define test targets**:
   ```ruby
   subject(:program) { described_class.new }
   subject(:new_model) { model.with(count: 5) }
   subject(:custom_model) { test_model_class.new(count: 5) }
   
   # For simple cases, use implicit subject
   subject { described_class.root }
   subject { described_class.env }
   ```

3. **Use `let` for test dependencies and lazy evaluation**:
   ```ruby
   let(:output) { StringIO.new }
   let(:new_model) { result.first }
   let(:message) { result.last }
   let(:original_children) { parent_model.children }
   ```

4. **Use `context` to group related scenarios and enable one-liners**:
   ```ruby
   # Good - Use context to set up scenarios for one-line tests
   context "when merging provided state with default state" do
     subject(:custom_model) { test_model_class.new(count: 5) }

     it { expect(custom_model.state[:count]).to eq(5) }
   end
   
   # Good - Group related one-line tests
   context "when checking child states" do
     subject(:child_count_model) { parent_model.children[0] }

     it { expect(child_count_model.state[:count]).to eq(5) }
   end
   ```

5. **Use `is_expected` when testing the subject directly**:
   ```ruby
   it { is_expected.to be_running }  # Preferred
   it { is_expected.not_to be(model) }
   it { is_expected.to be_a(Pathname) }
   it { is_expected.to eq(:test) }
   
   # vs - Avoid these when subject is available
   it { expect(subject).to be_running }
   it { expect(described_class.root).to be_a(Pathname) }
   ```

6. **Use `before` blocks for setup actions, not variable assignments**:
   ```ruby
   # Good - Setup actions in before blocks
   context "when configuring with block" do
     before do
       described_class.configure do |config|
         config.app_dir = "custom"
         config.hot_reloading = false
       end
     end

     it { expect(config.app_dir).to eq("custom") }
     it { expect(config.hot_reloading).to be(false) }
   end
   
   # Avoid - Variable assignments should use let/subject
   before do
     @config = described_class.configure { |c| c.app_dir = "custom" }
   end
   ```

7. **Use `.to change()` for testing immutability**:
   ```ruby
   it { expect { model.update(:increment) }.not_to change(model, :state) }
   it { expect { model.with(count: 5) }.not_to change(model, :state) }
   ```

7. **Each `it` block should have only one expectation**:
   ```ruby
   # Good - Separate one-line tests
   it { expect(new_model).not_to be(model) }
   it { expect(new_model.state[:count]).to eq(5) }
   
   # Avoid - Multiple expectations in one block
   it "creates new instance with updated state" do
     new_model = model.with(count: 5)
     expect(new_model).not_to be(model)
     expect(new_model.state[:count]).to eq(5)
   end
   ```

8. **Transform multi-line tests into context + one-liners**:
   ```ruby
   # Good - Use context to enable one-liner
   context "when called on base class" do
     subject(:base_model) { Milktea::Model.new }

     it { expect { base_model.view }.to raise_error(NotImplementedError) }
   end
   
   # Avoid - Multi-line when one-liner is possible
   it "raises NotImplementedError for base class" do
     base_model = Milktea::Model.new
     expect { base_model.view }.to raise_error(NotImplementedError)
   end
   ```

9. **Use descriptive blocks ONLY when one-liners are impossible**:
   ```ruby
   # Only use this when absolutely necessary (very rare)
   it "handles complex scenario with multiple setup steps" do
     # Multiple expectations or complex setup that cannot be simplified
   end
   ```

10. **PRIORITY: Transform ANY multi-line test into context + one-liner**:
    ```ruby
    # If you find yourself writing this:
    it "merges provided state with default state" do
      custom_model = test_model_class.new(count: 5)
      expect(custom_model.state[:count]).to eq(5)
    end
    
    # Transform it to this:
    context "when merging provided state with default state" do
      subject(:custom_model) { test_model_class.new(count: 5) }

      it { expect(custom_model.state[:count]).to eq(5) }
    end
    ```

11. **Never test private instance variables directly**:
    ```ruby
    # Bad - Testing implementation details
    it { expect(subject.instance_variable_get(:@output)).to eq($stdout) }
    
    # Good - Testing public behavior with one-liner
    it { expect(output.string).to include("expected content") }
    ```

12. **Focus on observable behavior, not implementation**:
    ```ruby
    # Bad - Checking internal state
    it { expect(program.instance_variable_get(:@renderer)).to be_a(Milktea::Renderer) }
    
    # Good - Testing actual public behavior with one-liner
    it { expect(runtime).to have_received(:stop) }
    ```

13. **Prefer `instance_double` over extensive `allow` calls**:
    ```ruby
    # Bad - Multiple allow calls
    let(:runtime) { instance_double(Milktea::Runtime) }
    before do
      allow(runtime).to receive(:start)
      allow(runtime).to receive(:running?).and_return(false)
      allow(runtime).to receive(:tick).and_return(model)
      allow(runtime).to receive(:render?).and_return(false)
    end
    
    # Good - Configure instance_double with expected methods
    let(:runtime) do
      instance_double(Milktea::Runtime, 
        start: nil,
        running?: false,
        tick: model,
        render?: false
      )
    end
    ```

13. **Use spies for testing delegation instead of expect().to receive()**:
    ```ruby
    # Bad - Pre-setting expectations
    it "delegates to runtime stop" do
      expect(runtime).to receive(:stop)
      program.stop
    end
    
    # Good - Using spy pattern
    let(:runtime) { spy('runtime', running?: false) }
    
    it "delegates to runtime stop" do
      program.stop
      expect(runtime).to have_received(:stop)
    end
    ```

14. **Use RSpec's `output` matcher for testing stdout/stderr**:
    ```ruby
    # Good - Using output matcher
    it "prints to stdout" do
      expect { renderer.render(model) }.to output("Hello!").to_stdout
    end
    
    # Also good - Testing with regex
    it "prints to stdout" do
      expect { renderer.render(model) }.to output(/Hello/).to_stdout
    end
    
    # Bad - Manual stdout capture
    it "prints to stdout" do
      stdout_capture = StringIO.new
      renderer = described_class.new(stdout_capture)
      renderer.render(model)
      expect(stdout_capture.string).to include("Hello!")
    end
    ```

15. **Use `allow(ENV).to receive(:fetch)` for environment variable mocking**:
    ```ruby
    # Good - Mock ENV.fetch calls
    before { allow(ENV).to receive(:fetch).with("MILKTEA_ENV", nil).and_return("test") }
    
    # Avoid - Direct ENV manipulation
    before { ENV["MILKTEA_ENV"] = "test" }
    after { ENV.delete("MILKTEA_ENV") }
    ```

16. **Structure module/class method tests with clear subject definitions**:
    ```ruby
    describe ".root" do
      subject { described_class.root }
      
      it { is_expected.to be_a(Pathname) }
    end
    
    describe ".env" do
      subject { described_class.env }
      
      it { is_expected.to be_a(Symbol) }
      
      context "when MILKTEA_ENV is set" do
        before { allow(ENV).to receive(:fetch).with("MILKTEA_ENV", nil).and_return("test") }
        
        it { is_expected.to eq(:test) }
      end
    end
    ```

17. **Use named subjects for configuration testing**:
    ```ruby
    describe ".configure" do
      subject(:config) { described_class.config }  # Named subject for clarity
      
      context "when configuring with block" do
        before do
          described_class.configure do |config|
            config.app_dir = "custom"
            config.hot_reloading = false
          end
        end
        
        it { expect(config.app_dir).to eq("custom") }
        it { expect(config.hot_reloading).to be(false) }
      end
    end
    ```

### RSpec Style Summary

**CRITICAL RULE**: Always prefer `it { ... }` one-line syntax. If you find yourself writing a multi-line `it` block, immediately refactor it into a `context` with a `subject` to enable one-line tests.

**The Golden Pattern**:
```ruby
context "when [scenario description]" do
  subject(:target) { SomeClass.new(params) }

  it { expect(target.method).to eq(expected) }
end
```

**Remember**: Every multi-line test can and should be transformed into this pattern.

## Important Notes

- Ruby version requirement: >= 3.1.0
- Uses conventional commits format in English
- The gemspec uses git to determine which files to include in the gem
- Currently in early development (v0.1.0) with core architecture implemented
- Runtime-based architecture allows dependency injection for testing and customization
- Program uses dependency injection pattern: `Program.new(model, runtime: custom_runtime)`

## Repository Management

- Keep ARCHITECTURE.md updated when we change anything