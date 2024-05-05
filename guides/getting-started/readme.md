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
```

## Run!

If you use the `Lennarb::Application::Base` class, you can use the `run!` method to run your app:

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

By default, the `run!` method does the following:

- Freeze the app routes
- Default middlewares:
  - `Lennarb::Middlewares::Logger`
  - `Lennarb::Middlewares::Static`
  - `Lennarb::Middlewares::NotFound`
  - `Lennarb::Middlewares::Lint`L
  - `Lennarb::Middlewares::ShowExceptions`
  - `Lennarb::Middlewares::MethodOverride`

After that, you can run your app with the `rackup` command:

```bash
$ rackup
```

## Hooks

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

## Not Found

You can use the `render_not_found` method to define a custom 404 page in the hooks context:

```ruby
require 'lennarb'

class App < Lennarb::Application::Base
	before do |context|
		render_not_found if context['PATH_INFO'] == '/not_found'
	end
end
```

You can pass your custom 404 page:

```ruby
before do |context|

	HTML = <<~HTML
	<!DOCTYPE html>
	<html>
		<head>
			<title>404 Not Found</title>
		</head>
		<body>
			<h1>404 Not Found</h1>
		</body>
	</html>
	HTML

	render_not_found HTML if context['PATH_INFO'] == '/not_found'
end
```

Lastly, you can create a custom 404 page and put in the `public` folder:

```sh
touch public/404.html
```

Now the default 404 page is your custom 404 page.

After that, you can run your app with the `rackup` command:

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
