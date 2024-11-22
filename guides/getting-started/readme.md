# Getting Started with Lennarb

## Overview

Lennarb is a lightweight, Rack-based web framework for Ruby that emphasizes simplicity and flexibility. It provides a clean DSL for routing, middleware support, and various ways to structure your web applications.

## Installation

Add Lennarb to your project's Gemfile:

```ruby
gem 'lennarb'
```

Or install it directly via RubyGems:

```bash
$ gem install lennarb
```

## Quick Start

### Basic Application

Create a new file named `config.ru`:

```ruby
require 'lennarb'

app = Lennarb.new do |app|
  app.get '/' do |req, res|
    res.status = 200
    res.html('<h1>Welcome to Lennarb!</h1>')
  end
end

run app
```

Start the server:

```bash
$ rackup
```

Your application will be available at `http://localhost:9292`.

## Application Structure

### Class-Based Applications

For larger applications, you can use a class-based structure:

```ruby
class MyApp < Lennarb
  # Routes
  get '/' do |req, res|
    res.status = 200
    res.html('<h1>Welcome to MyApp!</h1>')
  end

  post '/users' do |req, res|
    user = create_user(req.params)
    res.status = 201
    res.json(user.to_json)
  end
end

# config.ru
run MyApp.freeze!
```

### Instance-Based Applications

For simpler applications or prototypes:

```ruby
app = Lennarb.new do |l|
  l.get '/hello/:name' do |req, res|
    name = req.params[:name]
    res.status = 200
    res.text("Hello, #{name}!")
  end
end

run app
```

## Routing

### Available HTTP Methods

Lennarb supports all standard HTTP methods:

- `get(path, &block)`
- `post(path, &block)`
- `put(path, &block)`
- `patch(path, &block)`
- `delete(path, &block)`
- `head(path, &block)`
- `options(path, &block)`

### Route Parameters

Routes can include dynamic parameters:

```ruby
class API < Lennarb
  get '/users/:id' do |req, res|
    user_id = req.params[:id]
    user = User.find(user_id)

    res.status = 200
    res.json(user.to_json)
  end
end
```

### Response Helpers

Lennarb provides convenient response helpers:

```ruby
class App < Lennarb
  get '/html' do |req, res|
    res.html('<p>HTML Response</p>')
  end

  get '/json' do |req, res|
    res.json({ message: 'JSON Response' })
  end

  get '/text' do |req, res|
    res.text('Plain Text Response')
  end

  get '/redirect' do |req, res|
    res.redirect('/new-location')
  end
end
```

## Middleware Support

The plugin system is compatible with Rack middleware. To add middleware using the `use` method:

```ruby
class App < Lennarb
  # Built-in Rack middleware
  use Rack::Logger
  use Rack::Session::Cookie, secret: 'your_secret'

  # Custom middleware
  use MyCustomMiddleware, option1: 'value1'

  get '/' do |req, res|
    # Access middleware features
    logger = env['rack.logger']
    logger.info 'Processing request...'

    res.status = 200
    res.text('Hello World!')
  end
end
```

## Application Lifecycle

### Initialization

```ruby
class App < Lennarb
  # Configuration code here

  def initialize
    super
    # Custom initialization code
  end
end
```

### Freezing the Application

Call `freeze!` to finalize your application configuration:

```ruby
# config.ru
app = MyApp.freeze!
run app
```

After freezing:

- No new routes can be added
- No new middleware can be added
- The application becomes thread-safe

## Development vs Production

### Development

```ruby
# config.ru
require './app'

if ENV['RACK_ENV'] == 'development'
  use Rack::Reloader
  use Rack::ShowExceptions
end

run App.freeze!
```

### Production

```ruby
# config.ru
require './app'

if ENV['RACK_ENV'] == 'production'
  use Rack::CommonLogger
  use Rack::Runtime
end

run App.freeze!
```

## Best Practices

1. **Route Organization**

   ```ruby
   class App < Lennarb
     # Group related routes together
     # API routes
     get '/api/users' do |req, res|
       # Handle API request
     end

     # Web routes
     get '/web/dashboard' do |req, res|
       # Handle web request
     end
   end
   ```

2. **Error Handling**

   ```ruby
   class App < Lennarb
     get '/protected' do |req, res|
       raise AuthenticationError unless authenticated?(req)
       res.text('Secret content')
     rescue AuthenticationError
       res.status = 401
       res.json({ error: 'Unauthorized' })
     end
   end
   ```

3. **Modular Design**

   ```ruby
   # Split large applications into modules
   class AdminApp < Lennarb
     # Admin-specific routes
   end

   class MainApp < Lennarb
     plugin :mount
     mount AdminApp, at: '/admin'
   end
   ```

## Running Your Application

### Basic Usage

```bash
$ rackup
```

### With Environment Configuration

```bash
$ RACK_ENV=production rackup -p 3000
```

### With Custom Config File

```bash
$ rackup custom_config.ru
```

## Next Steps

- Explore the Plugin System for extending functionality
- Learn about Middleware Integration
- Check out Advanced Routing

## Support

For help and bug reports, please visit:

- GitHub Issues: [lennarb/issues](https://github.com/your-repo/lennarb/issues)
- Documentation: [lennarb.github.io](https://your-docs-site/lennarb)

Done! Now you can run your app!
