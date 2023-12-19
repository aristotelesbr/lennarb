# Middlewares

Middlewares are functions that are executed before the request handler. They are useful for tasks such as authentication, authorization, logging, etc.

The Lenna use two default middlewares: `Lenna::Middleware::ErrorHandler` and `Lenna::Middleware::Logging`

- `Lenna::Middleware::ErrorHandler` is responsible for handling errors and returning a response with the error message.

- `Lenna::Middleware::Logging` is responsible for logging the request and response.

## Creating a middleware

To create a middleware, you can use some object that responds to `#call` and receives `req`, `res` and `next_middleware` as arguments.

```ruby
# my_middleware.rb

class MyMiddleware
	def call(req, res, next_middleware)
		# Do something
		next_middleware.call
	end
end
```

The next middleware is a function that calls the next middleware in the chain. If there is no next middleware, it calls the request handler.

You can use a lambda to create a middleware:

```ruby

my_middleware = -> (req, res, next_middleware) {
	# Do something
	next_middleware.call
}
```

## Using a middleware

To use a middleware, you need to use `Lenna::Application#use`:

```ruby
# my_app.rb

require 'lennarb'

Lenna::Application.new do |route|
	route.get '/' do |req, res|
		res.html 'Hello World'
	end

	route.use(MyMiddleware)
end
```

Now, the `MyMiddleware` will be executed before the request handler.

## Using multiple middlewares

You can use multiple middlewares:

```ruby
# my_app.rb

require 'lennarb'

Lenna::Application.new do |route|
	route.get '/' do |req, res|
		res.html 'Hello World'
	end

	route.use([MyMiddleware, AnotherMiddleware])
end
```

Now, the `MyMiddleware` and `AnotherMiddleware` will be executed before the request handler.

## Using middlewares in a specific route

You can use middlewares in a specific route:

```ruby
# my_app.rb

require 'lennarb'

Lenna::Application.new do |route|
	route.get '/' do |req, res|
		res.html 'Hello World'
	end

	route.get '/users', MyMiddleware do |req, res|
		res.html 'Users'
	end
end
```

Now, the `MyMiddleware` will be executed before the request handler of `/users` route.

## Using middlewares in a specific nested namespace

In this version, you can't use middlewares in a specific nested namespace. But you can use middlewares in a specific namespace and use middlewares in a specific route.

Done, now you know how to use middlewares in Lennarb.
