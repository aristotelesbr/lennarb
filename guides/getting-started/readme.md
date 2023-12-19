# Getting Started

This guide show you how to use the `lennarb`

## Instalation

Add the gem to your project:

```bash
$ gem add lennarb
```

## Usage

To use the gem, you need to require and use `Lenna::Application` or `Leann::Base` to define your routes:

```ruby
# config.ru

require 'lennarb'

app = Lenna::Application.new do |route|
	route.get '/' do |req, res|
		res.html 'Hello World'
	end
end

run app
```

You can also use `Lenna::Base` to define your routes:

```ruby

class MyApp
	include Lenna::Base

	app.get '/' do |_req, res|
		res.html 'Hello World'
	end
end

run MyApp.new
```

When you include `Lenna::Base` in your class, it will define a app method that returns a `Lenna::Application` instance.

## Params

You can get params from the request using `req.params`:

```ruby
# app.rb

app.get '/hello/:name' do |req, res|
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
