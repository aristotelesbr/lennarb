# Plugin System

## Overview

The Lennarb Plugin System provides a modular way to extend your application's functionality. Built with simplicity and flexibility in mind, it allows you to seamlessly integrate new features and behaviors into your Lennarb applications through a clean and intuitive API.

## Core Features

- Simple plugin registration and loading
- Support for default and custom plugin directories
- Environment-based configuration
- Thread-safe plugin management
- Inheritance-aware plugin system

## Implementation Details

### The Plugin Module

The core of the plugin system is implemented in the `Lennarb::Plugin` module, which provides the following key functionality:

#### Registry Management

```ruby
Lennarb::Plugin.register(:plugin_name, PluginModule)
```

- Maintains a central registry of all available plugins
- Ensures unique plugin names using symbols as identifiers
- Thread-safe registration process

#### Plugin Loading

```ruby
Lennarb::Plugin.load(:plugin_name)
```

- Loads plugins on demand
- Raises `Lennarb::Plugin::Error` if plugin is not found
- Handles plugin dependencies automatically

#### Default Plugin Management

```ruby
Lennarb::Plugin.load_defaults!
```

- Automatically loads plugins from the default directory
- Supports custom plugin directories via `LENNARB_PLUGINS_PATH`
- Configurable through environment variables

## Creating Plugins

### Basic Plugin Structure

```ruby
module MyPlugin
  module ClassMethods
    def plugin_class_method
      # Class-level functionality
    end
  end

  module InstanceMethods
    def plugin_instance_method
      # Instance-level functionality
    end
  end

  def self.configure(app, options = {})
    # Plugin configuration logic
  end
end

Lennarb::Plugin.register(:my_plugin, MyPlugin)
```

### Plugin Components

1. **ClassMethods**: Extended into the Lennarb application class
2. **InstanceMethods**: Included in the Lennarb application instance
3. **configure**: Called when the plugin is loaded (optional)

## Using Plugins

### In a Class-based Application

```ruby
class MyApp < Lennarb
  plugin :hooks
  plugin :mount

  before '/admin/*' do |req, res|
    # Authentication logic
  end

  get '/users' do |req, res|
    res.status = 200
    res.json(users: ['John', 'Jane'])
  end
end
```

### In a Direct Instance

```ruby
app = Lennarb.new do |l|
  l.plugin :hooks

  l.get '/hello' do |req, res|
    res.status = 200
    res.text('Hello, World!')
  end
end
```

### Plugin Configuration

```ruby
class MyApp < Lennarb
  plugin :my_plugin, option1: 'value1', option2: 'value2'
end
```

## Built-in Plugins

### Hooks Plugin

Provides before and after hooks for request processing:

```ruby
plugin :hooks

before '/admin/*' do |req, res|
  authenticate_admin(req)
end

after '*' do |req, res|
  log_request(req)
end
```

### Mount Plugin

Enables mounting other Lennarb applications:

```ruby
plugin :mount

mount AdminApp, at: '/admin'
mount ApiV1, at: '/api/v1'
```

## Environment Configuration

The plugin system can be configured through environment variables:

- `LENNARB_PLUGINS_PATH`: Custom plugin directory paths (colon-separated)
- `LENNARB_AUTO_LOAD_DEFAULTS`: Enable/disable automatic loading of default plugins (default: true)

Example:

```bash
export LENNARB_PLUGINS_PATH="/app/plugins:/lib/plugins"
export LENNARB_AUTO_LOAD_DEFAULTS="true"
```

## Best Practices

1. **Plugin Naming**

   - Use descriptive, lowercase names
   - Avoid conflicts with existing plugins
   - Use underscores for multi-word names

2. **Error Handling**

   - Implement proper error handling in plugin code
   - Raise meaningful exceptions when appropriate
   - Document potential errors

3. **Configuration**

   - Keep plugin configuration simple and optional
   - Provide sensible defaults
   - Document configuration options

4. **Testing**
   - Write tests for your plugins
   - Test plugin interactions
   - Verify thread safety

## Troubleshooting

Common issues and solutions:

1. **Plugin Not Found**

   ```ruby
   Lennarb::Plugin::Error: Plugin my_plugin not found
   ```

   - Verify plugin is properly registered
   - Check plugin file location
   - Ensure proper require statements

2. **Plugin Directory Issues**
   ```ruby
   Lennarb::Plugin::Error: Plugin directory '/path/to/plugins' does not exist
   ```
   - Verify directory exists
   - Check permissions
   - Validate LENNARB_PLUGINS_PATH

