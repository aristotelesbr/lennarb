# Getting Started with Lennarb

## Overview

Lennarb is a minimalist, thread-safe Rack-based web framework for Ruby that focuses on simplicity and performance. It provides a clean routing DSL and straightforward request/response handling.

## Installation

Add Lennarb to your project's Gemfile:

```ruby
gem 'lennarb'
```

Or install it directly via RubyGems:

```bash
gem install lennarb
```

## Quick Start

### Basic Application

Create a new file named `config.ru`:

```ruby
require 'lennarb'

MyApp = Lennarb::App.new do
  routes
    get '/' do |req, res|
      res.status = 200
      res.html('<h1>Welcome to Lennarb!</h1>')
    end
  end
end

MyApp.initialize!
run App
```

Start the server:

```bash
rackup
```

Your application will be available at `http://localhost:9292`.

## Core Concepts

### Request Handling

Each route handler receives two arguments:

- `req`: A Request object wrapping the Rack environment
- `res`: A Response object for building the HTTP response

### Response Types

Lennarb provides three main response helpers:

```rb
app.get '/text' do |req, res|
  res.text('Plain text response')
end

app.get '/html' do |req, res|
  res.html('<h1>HTML response</h1>')
end

app.get '/json' do |req, res|
  res.json('{"message": "JSON response"}')
end
```

### Redirects

```ruby
app.get '/redirect' do |req, res|
  res.redirect('/new-location', 302) # 302
end
```

Routes are defined using HTTP method helpers:

```ruby
Lennarb::App.new do
  routes do
    get '/' do |req, res|
      res.html('Home page')
    end

    get '/users/:id' do |req, res|
      user_id = req.params[:id]
      res.json("{\"id\": #{user_id}}")
    end
  end
end
```

### Route Parameters

Parameters from dynamic route segments are available in `req.params`:

```ruby
get '/hello/:name' do |req, res|
  name = req.params[:name]
  res.text("Hello, #{name}!")
end
```

## Thread Safety

Lennarb is thread-safe by design:

- All request processing is synchronized using a mutex
- The router tree is frozen after initialization
- Response objects are created per-request

## Application Life-cycle

### Initialization

```ruby
Myapp = Lennarb::App.new do
  # Define routes
  routes do
  end

  # Define Configurations
  config do
  end
end

# Initialize and freeze the application
MyApp.initialize!
```

The `initialize!` method:

- Loads environment-specific dependencies
- Freezes the route tree
- Freezes the Rack application

### Environment

Lennarb uses the `LENNA_ENV` environment variable (defaults to "development"):

It can be set using the following environment variables:

- `LENNA_ENV`
- `APP_ENV`
- `RACK_ENV`

```bash
LENNA_ENV=production rackup
```

## Error Handling

Lennarb provides basic error handling:

```ruby
get '/api' do |req, res|
  # Errors are caught and return 500 with error message
  raise "Something went wrong"
end
```

Default error responses:

- 404 for unmatched routes
- 500 for application errors

## Best Practices

1. **Always call initialize!**

   ```ruby
   app = Lennarb::App.new
   app.initialize!
   run app
   ```

2. **Set response status**

   ```ruby
   get '/api' do |req, res|
     res.status = 200
     res.json('{"status": "ok"}')
   end
   ```

3. **Use appropriate response types**

   ```ruby
   # HTML for web pages
   res.html('<h1>Web Page</h1>')

   # JSON for APIs
   res.json('{"data": "value"}')

   # Text for simple responses
   res.text('Hello')
   ```

## Support

For help and bug reports, please visit:

- GitHub Issues: [lennarb/issues](https://github.com/aristotelesbr/lennarb/issues)

Now you can run your app!
