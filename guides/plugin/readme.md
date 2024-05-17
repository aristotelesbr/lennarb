# Plugin System

## Overview

The Lennarb Plugin System allows you to extend the functionality of your Lennarb application by registering and loading plugins. This system is designed to be simple and flexible, enabling you to add custom behaviors and features to your application effortlessly.

## Implementation Details

The plugin system is implemented using a module, `Lennarb::Plugin`, which centralizes the registration and loading of plugins.

### Module: `Plugins`

```ruby
class Lennarb
	module Plugins
		@plugins = {}

		def self.register_plugin(name, mod)
			@plugins[name] = mod
		end

		def self.load_plugin(name)
			@plugins[name] || raise("Plugin #{name} did not register itself correctly")
		end

		def self.plugins
			@plugins
		end
	end
end
```

## Usage

### Registering a Plugin

To register a plugin, define a module with the desired functionality and register it with the Plugin module.

```ruby
module MyCustomPlugin
  def custom_method
    "Custom Method Executed"
  end
end

Plugins.register(:my_custom_plugin, MyCustomPlugin)
```

### Load and Use a Plugin

To load and use a plugin in your Lennarb application, call the plugin method in your application class.

```ruby
Lennarb.new do |app|
	app.plugin :my_custom_plugin

	app.get '/custom' do |req, res|
		res.status = 200
		res.html(custom_method)
	end
end
```

And if you are using the `Lennarb::Application::Base` class, you can use the `plugin` method directly in your application class.

```ruby
class MyApp < Lennarb::Application::Base
  plugin :my_custom_plugin

  get '/custom' do |_req, res|
    res.status = 200
    res.html(custom_method)
  end
end
```

In this example, the custom_method defined in `MyCustomPlugin` is available in the routes of `MyApp`.

## Conclusion

The Lennarb Plugin System provides a simple and flexible way to extend your application's functionality. By registering and loading plugins, you can easily add custom behaviors and features to your Lennarb application.

