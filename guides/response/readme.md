# Response

This is the response guide.
The `res` object is used to send a response to the client. The Lennarb use a custom response object to send responses to the client. The `res` object is an instance of {Lennarb::Response}.

## Usage

You can use the `res` object to send a response to the client.

```ruby
# app.rb

app.get '/' do |req, res|
	res.html 'Hello World'
end
```

## Content Types

Lenna supports the following content types:

```ruby
# app.rb

app.get '/' do |req, res|
	res.html 'Hello World'
	res.json '{"message": "Hello World"}'
	res.text 'Hello World'
end
```

But you can also set your own content type:

```ruby
res.headers['Content-Type'] = 'text/markdown'
res.write '# Hello World'
```

## The write method

You can use the `res.write` method to write to the response body:

```ruby
# app.rb

app.get '/' do |req, res|
	res.write 'Hello World'
end
```

JSON example:

```ruby
# app.rb

app.post '/posts' do |req, res|
	req.params # => { name: 'Lenna' }

	res.write({ data: { name: } }.to_json) # This will write to the response body
end
```

## Headers

You can set headers using the `res.header` method:

```ruby
# app.rb

app.get '/' do |req, res|
	res['Content-Type'] = 'text/plain'
	res.write 'Hello World'
end
```

## Status Codes

You can set the status code using the `res.status` method:

```ruby
res.status 200
```

## Redirects

You can redirect the client using the `res.redirect` method:

```ruby
# app.ruby

app.get '/' do |req, res|
  # Stuff code here...
	res.redirect '/hello'
end
```
