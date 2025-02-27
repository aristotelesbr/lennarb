# Response

This is the response guide.
The `res` object is used to send a response to the client. The Lennarb use a custom response object to send responses to the client. The `res` object is an instance of {Lennarb::Response}.

## Usage

You can use the `res` object to send a response to the client.

```ruby
# app.rb

get '/' do |req, res|
 res.html 'Hello World'
end
```

## Content Types

Lennarb supports the following content types:

```ruby
# app.rb

get '/' do |req, res|
 res.html 'Hello World'
 res.json '{"message": "Hello World"}'
 res.text 'Hello World'
end
```

But you can also set your own content type:

```ruby
res['content-type'] = 'text/markdown'
res.write '# Hello World'
```

## The write method

You can use the `res.write` method to write to the response body:

```ruby
# app.rb

get '/' do |req, res|
 res.write 'Hello World'
end
```

JSON example:

```ruby
# app.rb

post '/posts' do |req, res|
 req.params # => { name: 'Lenna' }
 name = req.params[:name]

 res.write({ data: { name: } }.to_json) # This will write to the response body
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

get '/' do |req, res|
  # Stuff code here...
 res.redirect '/hello'
end
```
