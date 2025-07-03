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
- `/lib/milktea/` - Core framework implementation (to be developed)
- Uses TTY gems for terminal interaction (tty-box, tty-cursor, tty-reader, tty-screen)
- Event handling through the `timers` gem

## Testing Approach

- RSpec 3.x for unit testing
- Test files mirror the lib structure in the spec/ directory
- Monkey patching is disabled for cleaner tests
- Run individual tests with line numbers for focused development

## Important Notes

- Ruby version requirement: >= 3.1.0
- Uses conventional commits format in English
- The gemspec uses git to determine which files to include in the gem
- Currently in early development (v0.1.0) - main functionality needs to be implemented