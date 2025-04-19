<div align="center">
  <picture>
    <img alt="Lennarb" src="https://raw.githubusercontent.com/aristotelesbr/lennarb/refs/heads/main/logo/lennarb.svg" width="250">
  </picture>

  <hr>

  <p>A lightweight, fast, and modular web framework for Ruby based on Rack. <strong>Lennarb</strong> supports Ruby (MRI) 3.4+</p>

  <a href="https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml">
    <img src="https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml/badge.svg" alt="Test">
  </a>
  <a href="https://rubygems.org/gems/lennarb">
    <img src="https://img.shields.io/gem/v/lennarb.svg" alt="Gem">
  </a>
  <a href="https://rubygems.org/gems/lennarb">
    <img src="https://img.shields.io/gem/dt/lennarb.svg" alt="Gem">
  </a>
  <a href="https://tldrlegal.com/license/mit-license">
    <img src="https://img.shields.io/:License-MIT-blue.svg" alt="MIT License">
  </a>
</div>

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Basic Usage](#basic-usage)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Features

- Lightweight and modular architecture
- High-performance routing system
- Simple and intuitive API
- Support for middleware
- Flexible configuration options
- Two implementation options:
  - `Lennarb::App`: Minimalist approach for single applications
  - `Lennarb::Base`: Extended version for mounting multiple applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lennarb'
```

Or install it directly:

```bash
gem install lennarb
```

## Quick Start

Create a simple application with routes:

```ruby
require "lennarb"

app = Lennarb::App.new do
  routes do
    get("/") do |req, res|
      res.html("<h1>Welcome to Lennarb!</h1>")
    end

    get("/hello/:name") do |req, res|
      name = req.params[:name]
      res.html("Hello, #{name}!")
    end
  end
end

app.initialize!
run app  # In config.ru
```

Start with: `rackup`

## Basic Usage

### Creating a Simple Application

The `Lennarb::App` class is the core of the framework:

```ruby
require "lennarb"

class MyApp < Lennarb::App
  # Define configuration
  config do
    mandatory :database_url, string
    optional :port, int, 9292
  end

  # Define routes
  routes do
    get("/") do |req, res|
      res.html("<h1>Welcome!</h1>")
    end

    post("/users") do |req, res|
      # Access request data
      data = req.body
      res.json({status: "created", data: data})
    end
  end

  # Define hooks
  before do |req, res|
    # Run before every request
    puts "Processing request: #{req.path}"
  end

  after do |req, res|
    # Run after every request
    puts "Completed request: #{req.path}"
  end

  # Define helper methods
  helpers do
    def format_date(date)
      date.strftime("%Y-%m-%d")
    end
  end
end

run MyApp.new.initialize!
```

### Response Types

Lennarb provides various response methods:

```ruby
# HTML response
res.html("<h1>Hello World</h1>")

# JSON response
res.json({message: "Hello World"})

# Plain text response
res.text("Plain text response")

# Redirect
res.redirect("/new-location")

# Custom status code
res.json({error: "Not found"}, status: 404)
```

### Mounting Applications

For larger applications, use `Lennarb::Base` to mount multiple apps:

```ruby
class API < Lennarb::App
  routes do
    get("/users") do |req, res|
      res.json([{id: 1, name: "Alice"}, {id: 2, name: "Bob"}])
    end
  end
end

class Admin < Lennarb::App
  routes do
    get("/dashboard") do |req, res|
      res.html("<h1>Admin Dashboard</h1>")
    end
  end
end

class Application < Lennarb::Base
  # Add common middleware
  middleware do
    use Rack::Session::Cookie, secret: "your_secret"
  end

  # Mount applications at specific paths
  mount(API, at: "/api")
  mount(Admin, at: "/admin")
end

run Application.new.initialize!
```

## Documentation

For more detailed information, please see:

- [Getting Started](https://aristotelesbr.github.io/lennarb/guides/getting-started/index) - Setup and first steps
- [Response](https://aristotelesbr.github.io/lennarb/guides/response/index.html) - Response handling
- [Request](https://aristotelesbr.github.io/lennarb/guides/request/index.html) - Request handling
- [Mounting Applications](https://aristotelesbr.github.io/lennarb/guides/mounting-applications/index.html) - Working with multiple apps
- [Performance](https://aristotelesbr.github.io/lennarb/guides/performance/index.html) - Benchmarks showing Lennarb's routing algorithm efficiency

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

This project uses the [Developer Certificate of Origin](https://developercertificate.org/) and is governed by the [Contributor Covenant](https://www.contributor-covenant.org/).

## License

MIT License - see the [LICENSE](LICENSE) file for details.
