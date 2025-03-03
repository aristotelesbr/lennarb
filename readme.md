<div align="center">
  <picture>
    <img alt="Lennarb" src="./logo/lennarb.svg" width="250">
  </picture>

---

A lightweight, fast, and modular web framework for Ruby based on Rack. **Lennarb** supports Ruby (MRI) 3.4+

[![Test](https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml/badge.svg)](https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml)
[![Gem](https://img.shields.io/gem/v/lennarb.svg)](https://rubygems.org/gems/lennarb)
[![Gem](https://img.shields.io/gem/dt/lennarb.svg)](https://rubygems.org/gems/lennarb)
[![MIT License](https://img.shields.io/:License-MIT-blue.svg)](https://tldrlegal.com/license/mit-license)

</div>

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Performance](#performance)
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
  - `Lennarb::App`: Minimalist approach for complete control
  - `Lennarb::Application`: Extended version with common components

## Implementation Options

Lennarb offers two implementation approaches to suit different needs:

- **Lennarb::App**: Minimalist approach for complete control
- **Lennarb::Application**: Extended version with common components

See the [documentation](https://aristotelesbr.github.io/lennarb/guides/getting-started/index) for details on each implementation.

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

```ruby
require "lennarb"

app = Lennarb::App.new do
  config do
    mandatory :database_url, string
    optional :env, string, "production"
    optional :port, int, 9292
  end

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

## Performance

Lennarb is designed for high performance:

![RPS](https://raw.githubusercontent.com/aristotelesbr/lennarb/main/benchmark/rps.png)

| Position | Application | 10 RPS     | 100 RPS    | 1.000 RPS | 10.000 RPS |
| -------- | ----------- | ---------- | ---------- | --------- | ---------- |
| 1        | Lenna       | 126.252,36 | 108.086,55 | 87.111,91 | 68.460,64  |
| 2        | Roda        | 123.360,37 | 88.380,56  | 66.990,77 | 48.108,29  |
| 3        | Syro        | 114.105,38 | 80.909,39  | 61.415,86 | 46.639,81  |
| 4        | Hanami-API  | 68.089,18  | 52.851,88  | 40.801,78 | 27.996,00  |

See all [benchmark graphs](https://github.com/aristotelesbr/lennarb/blob/main/benchmark)

## Documentation

- [Getting Started](https://aristotelesbr.github.io/lennarb/guides/getting-started/index) - Setup and first steps
- [Performance](https://aristotelesbr.github.io/lennarb/guides/performance/index.html) - Benchmarks and optimization
- [Response](https://aristotelesbr.github.io/lennarb/guides/response/index.html) - Response handling
- [Request](https://aristotelesbr.github.io/lennarb/guides/request/index.html) - Request handling

## Key Features

```ruby
# Different response types
res.html("<h1>Hello World</h1>")
res.json("{\"message\": \"Hello World\"}")
res.text("Plain text response")

# Route parameters
get("/users/:id") do |req, res|
  user_id = req.params[:id]
  res.json("{\"id\": #{user_id}}")
end

# Redirects
res.redirect("/new-location")
```

For more examples and full documentation, see:
[Complete Lennarb Documentation](https://aristotelesbr.github.io/lennarb/guides/getting-started/index)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

This project uses the [Developer Certificate of Origin](https://developercertificate.org/) and is governed by the [Contributor Covenant](https://www.contributor-covenant.org/).

## License

MIT License - see the [LICENSE](LICENSE) file for details.
