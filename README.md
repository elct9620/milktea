# Milktea

[![Gem Version](https://badge.fury.io/rb/milktea.svg)](https://badge.fury.io/rb/milktea)
[![Ruby](https://github.com/elct9620/milktea/workflows/Ruby/badge.svg)](https://github.com/elct9620/milktea/actions)

A Terminal User Interface (TUI) framework for Ruby, inspired by [Bubble Tea](https://github.com/charmbracelet/bubbletea) from Go. Milktea brings the power of the Elm Architecture to Ruby, enabling you to build rich, interactive command-line applications with composable components and reactive state management.

## Features

- 🏗️ **Elm Architecture**: Immutable state management with predictable message flow
- 📦 **Container Layouts**: Flexbox-style layouts for terminal interfaces
- 🔄 **Hot Reloading**: Instant feedback during development (similar to web frameworks)
- 📱 **Responsive Design**: Automatic adaptation to terminal resize events
- 🧩 **Composable Components**: Build complex UIs from simple, reusable models
- 📝 **Text Components**: Unicode-aware text rendering with wrapping and truncation
- ⏱️ **Timing System**: Built-in support for animations and time-based updates
- 🎨 **Rich Terminal Support**: Leverage TTY gems for advanced terminal features

## Installation

Add Milktea to your application's Gemfile:

```ruby
gem 'milktea'
```

Or install directly:

```bash
gem install milktea
```

For development versions:

```ruby
gem 'milktea', git: 'https://github.com/elct9620/milktea'
```

## Quick Start

Here's a simple "Hello World" application:

```ruby
require 'milktea'

class HelloModel < Milktea::Model
  def view
    "Hello, #{state[:name]}! Count: #{state[:count]}"
  end

  def update(message)
    case message
    when Milktea::Message::KeyPress
      case message.value
      when "+"
        [with(count: state[:count] + 1), Milktea::Message::None.new]
      when "q"
        [self, Milktea::Message::Exit.new]
      else
        [self, Milktea::Message::None.new]
      end
    else
      [self, Milktea::Message::None.new]
    end
  end

  private

  def default_state
    { name: "World", count: 0 }
  end
end

# Simple approach using Application class
class MyApp < Milktea::Application
  root "HelloModel"
end

MyApp.boot
```

## Core Concepts

### Models & Elm Architecture

Milktea follows the Elm Architecture pattern with three core concepts:

- **Model**: Immutable state container
- **View**: Pure function that renders state to string
- **Update**: Handles messages and returns new state + side effects

```ruby
class CounterModel < Milktea::Model
  def view
    "Count: #{state[:count]} (Press +/- to change, q to quit)"
  end

  def update(message)
    case message
    when Milktea::Message::KeyPress
      handle_keypress(message)
    when Milktea::Message::Resize
      # Rebuild model with fresh class for new screen dimensions
      [with, Milktea::Message::None.new]
    else
      [self, Milktea::Message::None.new]
    end
  end

  private

  def default_state
    { count: 0 }
  end

  def handle_keypress(message)
    case message.value
    when "+"
      [with(count: state[:count] + 1), Milktea::Message::None.new]
    when "-"
      [with(count: state[:count] - 1), Milktea::Message::None.new]
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end
```

### Container Layout System

Milktea provides a flexbox-inspired layout system for building complex terminal interfaces:

```ruby
class AppLayout < Milktea::Container
  direction :column
  child HeaderModel, flex: 1
  child ContentModel, flex: 3  
  child FooterModel, flex: 1
end

class SidebarLayout < Milktea::Container
  direction :row
  child SidebarModel, flex: 1
  child MainContentModel, flex: 3
end
```

#### Key Container Features:

- **Direction**: `:row` or `:column` (default: `:column`)
- **Flex Properties**: Control size ratios between children
- **State Mapping**: Pass specific state portions to children
- **Bounds Calculation**: Automatic layout calculation and propagation

```ruby
class AdvancedContainer < Milktea::Container
  direction :row
  
  # Pass specific state to children with state mappers
  child SidebarModel, ->(state) { { items: state[:sidebar_items] } }, flex: 1
  child ContentModel, ->(state) { state.slice(:title, :content) }, flex: 2
  child InfoModel, flex: 1
end
```

### Hot Reloading (Development Feature)

Milktea supports hot reloading for rapid development iteration:

```ruby
# Configure hot reloading
Milktea.configure do |config|
  config.autoload_dirs = ["app/models", "lib/components"]
  config.hot_reloading = true
end

class DevelopmentModel < Milktea::Model
  def update(message)
    case message
    when Milktea::Message::Reload
      # Hot reload detected - rebuild with fresh class
      [with, Milktea::Message::None.new]
    # ... other message handling
    end
  end
end
```

When files change, Milktea automatically detects the changes and sends `Message::Reload` events. Simply handle this message by rebuilding your model with `[with, Milktea::Message::None.new]` to pick up the latest code changes.

### Terminal Resize Handling

Milktea automatically detects terminal resize events and provides a simple pattern for responsive layouts:

```ruby
class ResponsiveApp < Milktea::Container
  direction :column
  child HeaderModel, flex: 1
  child DynamicContentModel, flex: 4

  def update(message)
    case message
    when Milktea::Message::Resize
      # Only root model needs resize handling
      # All children automatically recalculate bounds
      [with, Milktea::Message::None.new]
    when Milktea::Message::KeyPress
      handle_keypress(message)
    else
      [self, Milktea::Message::None.new]
    end
  end
end
```

#### Resize Handling Key Points:

- **Root-Level Only**: Only the root model needs to handle `Message::Resize`
- **Automatic Cascading**: Child components automatically adapt to new dimensions
- **Bounds Recalculation**: Container layouts automatically recalculate flex distributions
- **Screen Methods**: Use `screen_width`, `screen_height`, `screen_size` for responsive logic

## Examples

Explore the `examples/` directory for comprehensive demonstrations:

- **[Simple Counter](examples/simple.rb)**: Basic Elm Architecture patterns
- **[Container Layout](examples/container_layout.rb)**: Flexbox-style layouts with resize support  
- **[Text Components](examples/text_demo.rb)**: Unicode text rendering with dual modes
- **[Animations](examples/tick_example.rb)**: Timing-based animations and dynamic content
- **[Hot Reload Demo](examples/hot_reload_demo.rb)**: Development workflow with instant updates
- **[Dashboard](examples/dashboard.rb)**: Complex multi-component layout

Run examples:

```bash
ruby examples/simple.rb
ruby examples/text_demo.rb
ruby examples/tick_example.rb
ruby examples/container_layout.rb
```

## Advanced Features

### Dynamic Child Resolution

Use symbols to dynamically resolve child components:

```ruby
class DynamicContainer < Milktea::Container
  direction :column
  child :header_component, flex: 1  # Calls header_component method
  child ContentModel, flex: 3       # Direct class reference

  private

  def header_component
    state[:show_advanced] ? AdvancedHeader : SimpleHeader
  end
end
```

### Custom Message Handling

Create custom messages for complex interactions:

```ruby
# Define custom message
CustomAction = Data.define(:action_type, :payload)

class CustomModel < Milktea::Model
  def update(message)
    case message
    when CustomAction
      handle_custom_action(message)
    # ... standard message handling
    end
  end

  private

  def handle_custom_action(message)
    case message.action_type
    when :save
      # Handle save action
      [with(saved: true), Milktea::Message::None.new]
    when :load
      # Handle load action
      [with(data: message.payload), Milktea::Message::None.new]
    end
  end
end
```

### Application vs Manual Setup

Choose between high-level Application class or manual setup:

```ruby
# High-level Application approach (recommended)
class MyApp < Milktea::Application
  root "MainModel"
end

MyApp.boot

# Manual setup (advanced)
config = Milktea.configure do |c|
  c.autoload_dirs = ["app/models"]
  c.hot_reloading = true
end

loader = Milktea::Loader.new(config)
loader.hot_reload if config.hot_reloading?

model = MainModel.new
program = Milktea::Program.new(model, config: config)
program.run
```

## API Reference

### Core Classes

- **`Milktea::Model`**: Base class for all UI components
- **`Milktea::Container`**: Layout container with flexbox-style properties
- **`Milktea::Text`**: Unicode-aware text component with dual rendering modes
- **`Milktea::Application`**: High-level application wrapper
- **`Milktea::Program`**: Main application runtime
- **`Milktea::Message`**: Standard message types for application events

### Message System

- **`Message::KeyPress`**: Keyboard input events with key details
- **`Message::Tick`**: Timing events with timestamps for animations
- **`Message::Exit`**: Application termination
- **`Message::Resize`**: Terminal size changes  
- **`Message::Reload`**: Hot reload events (development)
- **`Message::None`**: No-operation message (no render)

For detailed API documentation, see the [documentation website](https://rubydoc.info/gems/milktea).

## Development

After checking out the repo:

```bash
bin/setup                    # Install dependencies
bundle exec rake spec        # Run tests
bundle exec rake rubocop     # Check code style
bundle exec rake             # Run all checks
bin/console                  # Interactive prompt
```

### Testing

Milktea uses RSpec for testing. Run specific tests:

```bash
bundle exec rspec spec/milktea/model_spec.rb
bundle exec rspec spec/milktea/container_spec.rb:42  # Specific line
```

### Code Quality

The project uses RuboCop for code formatting:

```bash
bundle exec rake rubocop:autocorrect  # Fix auto-correctable issues
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elct9620/milktea.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

- Inspired by [Bubble Tea](https://github.com/charmbracelet/bubbletea) - Go TUI framework
- Built on the [TTY toolkit](https://ttytoolkit.org/) ecosystem
- Follows [Elm Architecture](https://guide.elm-lang.org/architecture/) principles