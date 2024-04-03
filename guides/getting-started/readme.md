# Getting Started

This guide show you how to use the `lennarb`

## Instalation

Add the gem to your project:

```bash
$ gem add lennarb
```

## Usage

A basic app looks like this:

```ruby
# config.ru

require 'lennarb'

app = Lenna.new

app.get '/' do |req, res|
	res.html 'Hello World'
end

run app
```

You can also use a block to define the app:

```ruby
# config.ru

require 'lennarb'

app = Lenna.new do |app|
	app.get '/' do |req, res|
		res.html 'Hello World'
	end
end

run app
```

## Use `Lennarb::Router` module

You can use the `Lennarb::Router` module to define routes using the `route` method:

```ruby
# app.rb

require 'lennarb'

class App
	include Lennarb::Router

	route.get '/' do |_req, res|
		res.status = 200
		res.html 'Hello World'
	end
end
```

The `route` method is a instance of `Lennarb`. So, you can use the following methods:

- `route.get`
- `route.post`
- `route.put`
- `route.delete`
- `route.patch`
- `route.options`
- `route.head`

Now you can use the `App` class in your `config.ru`:

```ruby
# config.ru

require_relative 'app'

run App.app
```

The `app` method freeze the routes and return a `Lennarb` instance.

## Parameters

You can get `params` from the request using `req.params`:

```ruby
# app.rb

route.get '/hello/:name' do |req, res|
	res.html "Hello #{req.params[:name]}"
end
```

## Run

```bash
$ rackup

Puma starting in single mode...
* Puma version: 6.4.0 (ruby 3.2.2-p53) ("The Eagle of Durango")
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 94360
* Listening on http://127.0.0.1:9292
* Listening on http://[::1]:9292
Use Ctrl-C to stop
^C- Gracefully stopping, waiting for requests to finish
=== puma shutdown: 2023-12-19 08:54:26 -0300 ===
```

Done! Now you can run your app!
