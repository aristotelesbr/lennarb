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

## Use `Lennarb::Application::Base` class

You can also use the `Lennarb::Application::Base` class to define your app:

```ruby
# config.ru

require 'lennarb'

class App < Lennarb::Application::Base
end
```

## Define routes

When you use the `Lennarb::Application::Base` class, you can use the following methods:

- `get`
- `post`
- `put`
- `delete`
- `patch`
- `head`
- `options`

```ruby
# config.ru

require 'lennarb'

class App < Lennarb::Application::Base
	get '/' do |req, res|
		res.html 'Hello World'
	end
end

run App.new
```

## Run!

You can use `run!` method to run your app to use default configurations, like:

```ruby
# config.ru

require 'lennarb'

class App < Lennarb::Application::Base
	get '/' do |req, res|
		res.html 'Hello World'
	end
end

App.run!
```

- Freeze the app routes
- Default middlewares:
	- `Lennarb::Middlewares::Logger`
	- `Lennarb::Middlewares::Static`
	- `Lennarb::Middlewares::NotFound`
	- `Lennarb::Middlewares::Lint`L
	- `Lennarb::Middlewares::ShowExceptions`
	- `Lennarb::Middlewares::MethodOverride`

After that, you can run your app with the `rackup` command:

## Callbacks

You can use the `before` and `after` methods to define callbacks:

```ruby
# config.run

require 'lennarb'

class App < Lennarb::Application::Base
	before do |req, res|
		puts 'Before'
	end

	get '/' do |req, res|
		res.html 'Hello World'
	end

	after do |req, res|
		puts 'After'
	end
end

run App.run!
```

You can also use the `before` and `after` methods to define callbacks for specific routes:

```ruby
# config.ru

require 'lennarb'

class App < Lennarb::Application::Base
	before '/about' do |req, res|
		puts 'Before about'
	end

	get '/about' do |req, res|
		res.html 'About'
	end

	after '/about' do |req, res|
		puts 'After about'
	end
end
```

## Middlewares

You can use the `use` method to add middlewares:

```ruby

# config.ru

require 'lennarb'

class App < Lennarb::Application::Base
	use Lennarb::Middlewares::Logger
	use Lennarb::Middlewares::Static

	get '/' do |req, res|
		res.html 'Hello World'
	end
end

run App.run!
```

## Custom 404 page

If you are using `run!` method, you can use the custom 404 page just creating a `404.html` file in the `public` folder.

## Custom 500 page

TODO

## Run your app

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
