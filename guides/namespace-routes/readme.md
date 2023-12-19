# Namespace routes

This guide show you how to use namespace routes.

## Usage

To use namespace routes, you need to use `Lenna::Application#namespace`:

```ruby
# my_app.rb

require 'lennarb'

Lenna::Application.new do |route|
	route.namespace '/api' do |api|
		api.get '/users' do |req, res|
			res.json [{ name: 'John' }, { name: 'Doe' }]
		end
	end
end
```

Now, you have a route `/api/users` that returns a JSON with users.

```bash
$ curl http://localhost:9292/api/users

[{"name":"John"},{"name":"Doe"}]
```

## Nested namespaces

You also can use nested namespaces:

```ruby
# my_app.rb

require 'lennarb'

Lenna::Application.new do |route|
	route.namespace '/api' do |api|
		api.namespace '/v1' do |v1|
			v1.get '/users' do |req, res|
				res.json [{ name: 'John' }, { name: 'Doe' }]
			end
		end
		api.namespace '/v2' do |v2|
			v2.get '/users' do |req, res|
				res.json [{ name: 'John' }, { name: 'Doe' }]
			end
		end
	end
end
```

Now, you have a route `/api/v1/users` that returns a JSON with users.

```bash
$ curl http://localhost:9292/api/v1/users

[{"name":"John"},{"name":"Doe"}]
```

And a route `/api/v2/users` that returns a JSON with users.

```bash
$ curl http://localhost:9292/api/v2/users

[{"name":"John"},{"name":"Doe"}]
```

## Middlewares

The next version of Lenna will support middlewares in namespaces. For now, you can use `Lenna::Application#use`:

Done! Now you can use namespace routes in your app.
