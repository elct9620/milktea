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

## Application Development

### Using Milktea::Application (Recommended)

The simplest way to create Milktea applications is using the Application class:

```ruby
# Configure Milktea
Milktea.configure do |c|
  c.autoload_dirs = ["app/models"]
  c.hot_reloading = true
end

# Define Application class
class MyApp < Milktea::Application
  root "MainModel"
end

# Start the application
MyApp.boot
```

### Manual Setup (Advanced)

For advanced use cases, you can manually configure the components:

```ruby
# Configure with models directory paths
config = Milktea.configure do |c|
  # IMPORTANT: autoload_dirs must point to directories containing models for Zeitwerk
  c.autoload_dirs = ["examples/hot_reload_demo/models"]
  c.hot_reloading = true
end

# Create independent loader
loader = Milktea::Loader.new(config)
loader.hot_reload # Manually start hot reloading

# Create and run program
model = DemoModel.new
program = Milktea::Program.new(model, config: config)
```

## Hot Reloading Development

### Critical Implementation Details

1. **autoload_dirs Path Configuration**:
   - `autoload_dirs` is an array of directories relative to project root
   - For examples without Gemfile, include full path: `["examples/hot_reload_demo/models"]`
   - Must point to directories containing models (Zeitwerk requirement)
   - Multiple directories can be specified: `["app/models", "lib/components"]`

2. **Model Reload Handling**:
   - Models must handle `Message::Reload` events
   - Use `with` method to rebuild model instances with fresh classes
   ```ruby
   when Milktea::Message::Reload
     # Hot reload detected - rebuild model with fresh class
     [with, Milktea::Message::None.new]
   ```

3. **Class Reference in Model#with**:
   - Use `Kernel.const_get(self.class.name).new(merged_state)` instead of `self.class.new`
   - This ensures fresh class definitions are used after reload
   - `self.class` returns cached/old class objects during hot reload

4. **File Structure Requirements**:
   - Zeitwerk requires models to be in a `models/` directory
   - File names must match class names (e.g., `demo_model.rb` for `DemoModel`)
   - Use conventional Ruby file naming (snake_case files, PascalCase classes)

### Testing Hot Reloading

1. Run the hot reload demo: `ruby examples/hot_reload_demo.rb`
2. Edit files in `examples/hot_reload_demo/models/` while program is running
3. Save changes and observe immediate updates in the running program
4. Try modifying:
   - View content and layout
   - Key bindings and behavior
   - State structure and default values
   - Child model interactions

### Application Class Features

- **Auto-registration**: Inheriting from `Application` automatically sets `Milktea.app`
- **Root model definition**: Use `root "ModelName"` to specify the entry point model
- **Simple startup**: Call `MyApp.boot` instead of manual instantiation
- **Automatic loader setup**: Loader configuration and setup handled automatically
- **Hot reloading integration**: Automatically starts hot reloading if configured

## Dynamic Child Resolution

### Symbol-Based Child Definitions

All Model classes support dynamic child resolution using Symbols that reference methods returning Class objects:

```ruby
class DynamicModel < Milktea::Model
  child :dynamic_child  # References dynamic_child method
  child SomeClass       # Traditional class reference
  
  def dynamic_child
    state[:use_special] ? SpecialModel : RegularModel
  end
end
```

### Container Dynamic Layouts

Containers can dynamically switch between layout types while preserving bounds:

```ruby
class LayoutContainer < Milktea::Container
  direction :column
  child :status_bar, flex: 1
  child :dynamic_layout, flex: 5
  
  def status_bar
    StatusBarModel
  end
  
  def dynamic_layout
    state[:show_column] ? ColumnLayoutModel : RowLayoutModel
  end
end
```

### Error Handling

- **NoMethodError**: Thrown when Symbol references non-existent method
- **ArgumentError**: Thrown when method returns non-Model class
- Clear error messages distinguish between missing methods and invalid types

### Troubleshooting

- **Models not reloading**: Check `autoload_dirs` points to correct models directories
- **Old behavior persists**: Ensure `Kernel.const_get` is used in `Model#with`
- **Reload events ignored**: Verify `Message::Reload` handling in model `update` method
- **Listen gem not found**: Install with `gem install listen` for file watching

## Architecture

This project follows Clean Architecture and Domain-Driven Design (DDD) principles. The codebase structure:

- `/lib/milktea.rb` - Main module entry point with Zeitwerk autoloading and app registry
- `/lib/milktea/application.rb` - High-level Application abstraction with auto-registration
- `/lib/milktea/config.rb` - Configuration system with autoload_dirs array support
- `/lib/milktea/loader.rb` - Zeitwerk autoloading and hot reloading with multiple directory support
- `/lib/milktea/model.rb` - Base Model class for Elm Architecture components with child model DSL and dynamic child resolution
- `/lib/milktea/runtime.rb` - Message processing and execution state management
- `/lib/milktea/program.rb` - Main TUI program with event loop and dependency injection
- `/lib/milktea/message.rb` - Message definitions for events
- Uses TTY gems for terminal interaction (tty-box, tty-cursor, tty-reader, tty-screen)
- Event handling through the `timers` gem

### Core Components

- **Application**: High-level abstraction that encapsulates Loader and Program setup for simplified usage
- **Model**: Base class implementing Elm Architecture with immutable state and dynamic child resolution
- **Runtime**: Manages message queue and execution state with dependency injection support  
- **Program**: Handles terminal setup, rendering, and main event loop
- **Loader**: Manages Zeitwerk autoloading and hot reloading with Listen gem integration
- **Config**: Configuration system supporting multiple autoload directories and hot reloading settings
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
         config.autoload_dirs = ["custom"]
         config.hot_reloading = false
       end
     end

     it { expect(config.autoload_dirs).to eq(["custom"]) }
     it { expect(config.hot_reloading).to be(false) }
   end
   
   # Avoid - Variable assignments should use let/subject
   before do
     @config = described_class.configure { |c| c.autoload_dirs = ["custom"] }
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
            config.autoload_dirs = ["custom"]
            config.hot_reloading = false
          end
        end
        
        it { expect(config.autoload_dirs).to eq(["custom"]) }
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

## Container Layout System

### Flexbox-Style Layout

Container provides CSS-like flexbox layout for terminal interfaces:

```ruby
class MyContainer < Milktea::Container
  direction :row  # or :column (default)
  child HeaderModel, flex: 1
  child ContentModel, flex: 3
  child FooterModel, flex: 1
end
```

### Bounds Management

- Containers automatically calculate and propagate bounds (width, height, x, y)
- Child components receive properly sized layout areas
- Supports nested containers with accurate bounds calculation
- Dynamic components maintain proper bounds through Symbol resolution

### Default Container Behavior

- Container automatically displays `children_views` (no need for manual `view` method)
- Subclasses can override `view` for custom display logic
- Layout direction defaults to `:column` if not specified

## Important Notes

- Ruby version requirement: >= 3.2.0
- Uses conventional commits format in English
- The gemspec uses git to determine which files to include in the gem
- Currently in early development (v0.1.0) with core architecture implemented
- Runtime-based architecture allows dependency injection for testing and customization
- Program uses dependency injection pattern: `Program.new(model, runtime: custom_runtime)`
- Application auto-registers itself when inherited: `class MyApp < Milktea::Application` sets `Milktea.app = MyApp`
- Thread-safe app registry using mutex for concurrent access
- Dynamic child resolution available framework-wide through Symbol-based definitions

## Repository Management

- Keep ARCHITECTURE.md updated when we change anything

## Development Preferences

- Prefer using `return ... if` style instead of `if ... else` for early returns or value determination
- When using `return .. if`, prioritize returning error conditions first, use `unless` when necessary
