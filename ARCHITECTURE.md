# Milktea: Elm Architecture Reactive TUI Framework

## Overview

Milktea is a Ruby Terminal User Interface (TUI) framework inspired by The Elm Architecture. It provides a functional, reactive approach to building interactive command-line applications with predictable state management and composable components.

## Core Concepts

### Terminology

- **Model**: A ViewModel that encapsulates both state and behavior for a component
- **Message**: An event that triggers state changes, replacing traditional commands
- **Program**: The main event loop that manages rendering and message processing

### Architecture Principles

1. **Unidirectional Data Flow**: Messages flow through the update cycle in a predictable manner
2. **Immutable State**: Models create new instances rather than mutating existing state
3. **Pure Functions**: View and update methods produce consistent outputs for the same inputs
4. **Composable Components**: Models can contain child models forming a tree structure

## Architecture Diagrams

### Model-Update-View Cycle

```mermaid
graph TB
    User[User Input] --> Message[Message]
    Message --> Update[Model#update]
    Update --> NewModel[New Model]
    NewModel --> View[Model#view]
    View --> Render[Terminal Output]
    Render --> User
    
    Update --> SideEffect[Side Effects]
    SideEffect --> Message
    
    style Message fill:#e1f5fe
    style Update fill:#fff3e0
    style View fill:#f3e5f5
    style NewModel fill:#e8f5e8
```

### Component Composition

```mermaid
graph TB
    AppModel[App Model] --> CounterModel[Counter Model]
    AppModel --> TodoModel[Todo Model]
    AppModel --> StatusModel[Status Model]
    
    CounterModel --> ButtonModel1[Button Model]
    CounterModel --> LabelModel[Label Model]
    
    TodoModel --> TodoItem1[Todo Item 1]
    TodoModel --> TodoItem2[Todo Item 2]
    TodoModel --> TodoItem3[Todo Item 3]
    
    subgraph "State Management"
        AppModel
    end
    
    subgraph "UI Components"
        CounterModel
        TodoModel
        StatusModel
    end
    
    subgraph "Leaf Components"
        ButtonModel1
        LabelModel
        TodoItem1
        TodoItem2
        TodoItem3
    end
```

### Message Flow

```mermaid
sequenceDiagram
    participant User
    participant Program
    participant Model
    participant Child
    participant Terminal
    
    User->>Program: Keyboard Input
    Program->>Program: Map to Message
    Program->>Model: update(message)
    Model->>Child: update(child_message)
    Child-->>Model: [new_child, side_effect]
    Model-->>Program: [new_model, side_effect]
    Program->>Program: Execute Side Effects
    Program->>Model: view()
    Model->>Child: view()
    Child-->>Model: rendered_output
    Model-->>Program: composed_output
    Program->>Terminal: Display Output
```

### Auto Reloading Mechanism

```mermaid
graph TB
    FileWatcher[File Watcher] --> CodeReload[Code Reload]
    CodeReload --> ClassUpdate[Update Class Definitions]
    ClassUpdate --> StatePreservation[Preserve Current State]
    StatePreservation --> ModelRecreation[Recreate Model Instances]
    ModelRecreation --> ContinueExecution[Continue Execution]
    
    subgraph "Development Mode"
        FileWatcher
        CodeReload
        ClassUpdate
    end
    
    subgraph "State Management"
        StatePreservation
        ModelRecreation
        ContinueExecution
    end
    
    style FileWatcher fill:#e3f2fd
    style StatePreservation fill:#fff8e1
    style ModelRecreation fill:#f1f8e9
```

## Core Implementation

### Model Base Class

```ruby
module Milktea
  class Model
    def initialize(state = {}, children: [])
      @state = default_state.merge(state).freeze
      @children = children.freeze
    end
    
    def view
      raise NotImplementedError, "#{self.class} must implement #view"
    end
    
    def update(message)
      raise NotImplementedError, "#{self.class} must implement #update"
    end
    
    def with(new_state = {})
      self.class.new(@state.merge(new_state), children: @children)
    end
    
    def with_children(new_children)
      self.class.new(@state, children: new_children)
    end
    
    def add_child(child)
      self.class.new(@state, children: @children + [child])
    end
    
    def update_child(index, new_child)
      new_children = @children.dup
      new_children[index] = new_child
      self.class.new(@state, children: new_children)
    end
    
    protected
    
    def state
      @state
    end
    
    def children
      @children
    end
    
    private
    
    def default_state
      {}
    end
  end
end
```

### Message System

```ruby
module Milktea
  module Message
    # System messages
    None = Data.define
    Quit = Data.define
    Tick = Data.define
    ReloadDetected = Data.define
    
    # Input messages
    KeyPress = Data.define(:key)
    KeyUp = Data.define
    KeyDown = Data.define
    KeyEnter = Data.define
    KeyEscape = Data.define
    
    # Side effect messages
    Later = Data.define(:delay, :message)
    Batch = Data.define(:messages)
    
    # Component messages
    ChildMessage = Data.define(:child_index, :message)
  end
end
```

### Runtime Implementation

```ruby
module Milktea
  class Runtime
    def initialize(queue: Queue.new)
      @queue = queue
      @running = false
      @should_render = false
    end

    def tick(model)
      has_render_messages = false

      until @queue.empty?
        message = @queue.pop(true) # non-blocking pop
        model, side_effect = model.update(message)
        execute_side_effect(side_effect)

        # Only Message::None instances should not trigger render
        has_render_messages = true unless message.is_a?(Message::None)
      end

      @should_render = has_render_messages
      model
    end

    def render?
      @should_render
    end

    def stop?
      !@running
    end

    def running?
      @running
    end

    def start
      @running = true
    end

    def stop
      @running = false
    end

    def enqueue(message)
      @queue << message
    end

    private

    def execute_side_effect(side_effect)
      case side_effect
      when Message::None
        # Do nothing
      when Message::Exit
        stop
      when Message::Batch
        side_effect.messages.each { |msg| enqueue(msg) }
      end
    end
  end
end
```

### Program Implementation

```ruby
module Milktea
  class Program
    FPS = 60
    REFRESH_INTERVAL = 1.0 / FPS
    
    def initialize(model, runtime: nil, output: $stdout)
      @model = model
      @runtime = runtime || Runtime.new
      @output = output
      @timers = Timers::Group.new
    end
    
    def run
      @runtime.start
      setup_screen
      render
      setup_timers
      @timers.wait while running?
    ensure
      restore_screen
    end
    
    def stop
      @runtime.stop
    end

    def running?
      @runtime.running?
    end
    
    private
    
    def process_messages
      @model = @runtime.tick(@model)
      render if @runtime.render?
    end
    
    def render
      content = @model.view
      @output.print content
      @output.flush
    end

    def setup_timers
      # Main event loop
      @timers.now_and_every(REFRESH_INTERVAL) do
        process_messages
      end
    end
    
    def setup_screen
      # Terminal setup can be added here
    end
    
    def restore_screen
      # Terminal cleanup can be added here
    end
  end
end
```

## Usage Examples

### Simple Counter

```ruby
class Counter < Milktea::Model
  private
  
  def default_state
    { count: 0 }
  end
  
  public
  
  def view
    TTY::Box.frame(
      "Count: #{state[:count]}\n\n" \
      "Press 'i' to increment\n" \
      "Press 'r' to reset\n" \
      "Press 'q' to quit",
      title: "Counter"
    )
  end
  
  def update(message)
    case message
    when Milktea::Message::KeyPress
      case message.key
      when 'i'
        [with(count: state[:count] + 1), Milktea::Message::None.new]
      when 'r'
        [with(count: 0), Milktea::Message::None.new]
      when 'q'
        [self, Milktea::Message::Exit.new]
      else
        [self, Milktea::Message::None.new]
      end
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Usage
counter = Counter.new
program = Milktea::Program.new(counter)
program.run
```

### Composite Component

```ruby
class Dashboard < Milktea::Model
  def initialize(state = {}, children: [])
    default_children = [
      Counter.new,
      StatusBar.new(message: "Ready")
    ]
    super(state, children: children.presence || default_children)
  end
  
  def view
    content = [
      "=== Dashboard ===",
      "",
      children[0].view,  # Counter
      "",
      children[1].view   # Status Bar
    ].join("\n")
    
    TTY::Box.frame(content, padding: 1)
  end
  
  def update(message)
    case message
    when Milktea::Message::KeyPress
      case message.key
      when '1'
        # Route to counter
        counter = children[0]
        new_counter, side_effect = counter.update(message)
        [update_child(0, new_counter), side_effect]
      else
        [self, Milktea::Message::None.new]
      end
    else
      [self, Milktea::Message::None.new]
    end
  end
end
```

## Auto Reloading Support

### Development Mode

The framework supports automatic code reloading during development:

```ruby
class DevProgram < Milktea::Program
  def initialize(initial_model, watch_paths: [])
    super(initial_model)
    @reloader = setup_reloader(watch_paths)
  end
  
  private
  
  def setup_reloader(watch_paths)
    # Implementation using Zeitwerk and file watching
    # Preserves current model state during reloads
  end
  
  def handle_reload
    # Extract current state
    current_state = extract_state(@model)
    
    # Reload code
    @reloader.reload
    
    # Recreate model with preserved state
    @model = recreate_model_with_state(current_state)
  end
end
```

### State Preservation Strategy

1. **Extract State**: Recursively extract state from model tree
2. **Reload Code**: Update class definitions
3. **Recreate Models**: Instantiate new models with preserved state
4. **Continue Execution**: Resume normal operation

## Performance Optimization

### Rendering Optimization

1. **Message-Based Rendering**: Only re-render when non-None messages are processed
2. **Atomic Output**: Clear screen and output content in one operation to minimize flicker
3. **Batch Processing**: Process all pending messages before rendering once

### Memory Management

1. **Immutable Models**: Use structural sharing where possible
2. **Frozen State**: Prevent accidental mutations
3. **Efficient Updates**: Minimize object creation during updates

## Testing Strategy

### Unit Testing Models

```ruby
RSpec.describe Counter do
  subject(:counter) { described_class.new }
  
  describe '#update' do
    context 'with increment message' do
      let(:message) { Milktea::Message::KeyPress.new(key: 'i') }
      
      it 'increments the count' do
        new_model, _side_effect = counter.update(message)
        expect(new_model.send(:state)[:count]).to eq(1)
      end
    end
  end
  
  describe '#view' do
    it 'renders the current count' do
      expect(counter.view).to include('Count: 0')
    end
  end
end
```

### Integration Testing

```ruby
RSpec.describe Milktea::Program do
  let(:initial_model) { Counter.new }
  let(:output) { StringIO.new }
  subject(:program) { described_class.new(initial_model, output: output) }
  
  describe '#run' do
    it 'renders initial model' do
      program.run
      expect(output.string).to include('Count: 0')
    end
  end
end
```

## Design Principles

### Simplicity First

- Minimal API surface
- Clear separation of concerns
- Predictable behavior

### Developer Experience

- Hot reloading for rapid development
- Clear error messages
- Comprehensive documentation

### Performance

- Efficient rendering pipeline
- Minimal memory allocation
- Responsive user interface

## Future Development

### Planned Features

1. **Advanced Layout System**: Flexbox-like layout for complex UIs
2. **Animation Support**: Smooth transitions and effects
3. **Plugin Architecture**: Extensible middleware system
4. **Dev Tools**: Time travel debugging and performance profiling

### Community

- Clear contribution guidelines
- Comprehensive examples
- Active maintenance and support

## Conclusion

Milktea provides a solid foundation for building interactive terminal applications using functional programming principles. The framework's simplicity, combined with powerful features like auto-reloading and composable components, makes it an excellent choice for Ruby developers building CLI tools and TUI applications.

The architecture ensures predictable behavior, easy testing, and maintainable code while providing the flexibility needed for complex terminal interfaces.