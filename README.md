# Lennarb

Lennarb is a experimental lightweight, fast, and modular web framework for Ruby based on Rack.

## Table of Contents

- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
    - [Routing](#routing)
        - [Parameters](#parameters)
        - [Namespaces](#namespaces)
        - [Middlewares](#middlewares)
    - [Render HTML templates](#render-html-templates)
    - [Render JSON](#render-json)
    - [TODO](#todo)
- [Development](#development)
- [Contributing](#contributing)

## About

Lennarb is designed to be simple and easy to use, while still providing the power and flexibility of a full-featured web framework. Also, that's how I affectionately call my wife.

## Installation

Add this line to your application's Gemfile:


```rb
gem 'lennarb'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install lennarb
```

## Usage

After installing, you can begin using Lennarb to build your modular web applications with Ruby. Here is an example of how to get started:

```rb
app = Lenna::Base.new

app.get('/hello/:name') do |req, res|
    name = req.params[:name]

    res.html("Hello #{name}!")
end

app.listen(8000)
```

This example creates a new Lennarb application, defines a route for the `/hello/:name` path, and then starts the application on port 8000. When a request is made to the `/hello/:name` path, the application will respond with `Hello <name>!`, where `<name>` is the value of the `:name` parameter in the request path.

### Routing

Lennarb uses a simple routing system that allows you to define routes for your application. Routes are defined using the `get`, `post`, `put`, `patch`, `delete`. These methods take three arguments: the path to match, an Array of the middlewares that can be apply on the current route and a block to execute when a request is made to the path. The block is passed two arguments: the [`request`](https://github.com/aristotelesbr/lennarb/blob/main/lib/lenna/router/request.rb) object and the [`response`](https://github.com/aristotelesbr/lennarb/blob/main/lib/lenna/router/response.rb) object. The request object contains information about the request, such as the request method, headers, and body. The response object contains methods for setting the response status code, headers, and body. Ex.

```rb
app.get('/hello') do |_req, res|
    res.html('Hello World!')
end
```

The example above defines a route for the `/hello` path. When a request is made to the `/hello` path, the application will respond with `Hello World!`.

#### Parameters

Lennarb allows you to define parameters in your routes. Parameters are defined using the `:` character, followed by the name of the parameter. Parameters are passed to the route block as a hash in the request object's `params` property.

```rb
app.get('/hello/:name') do |req, res|
    name = req.params[:name]

    res.html("Hello #{name}!")
end
```

The example above defines a route for the `/hello/:name` path. When a request is made to the `/hello/:name` path, the application will respond with `Hello <name>!`, where `<name>` is the value of the `:name` parameter in the request path.

#### namespaces

Lennarb allows you to define namespaces in your routes. Namespaces are defined using the `namespace` method on the application object. Namespaces are passed to the route block as a hash in the request object's `params` property.

```rb
app.namespace('/api') do |router|
    roter.get('/hello') do |_req, res|
        res.html('Hello World!')
    end
end
```

The example above defines a namespace for the `/api` path. When a request is made to the `/api/hello` path, the application will respond with `Hello World!`.

#### Middlewares

The Lennarb application object has a `use` method that allows you to add middleware to your application. Middleware is defined using the `use` method on the application object. Ex.

```rb
app.get('/hello') do |_req, res|
    res.html('Hello World!')
end

app.use(Lenna::Middleware::Logger)
```

You can also define middleware for specific route.

```rb
app.get('/hello', TimeMiddleware) do |_req, res|
    res.html('Hello World!')
end
```

You can create your own middleware by creating a class that implements the `call` method. This methods receive three

```rb
class TimeMiddleware
    def call(req, res, next_middleware)
        puts Time.now

        req.headers['X-Time'] = Time.now

        next_middleware.call
    end
end
```

Or using a lambda functions.

```rb
TimeMiddleware = ->(req, res, next_middleware) do
    puts Time.now

    req.headers['X-Time'] = Time.now

    next_middleware.call
end
```

So you can use it like this:

```rb
app.get('/hello', TimeMiddleware) do |_req, res|
    res.html('Hello World!')
end
```

And you can use multiple middlewares on the same route.

```rb
app.get('/hello', [TimeMiddleware, LoggerMiddleware]) do |_req, res|
    res.html('Hello World!')
end
```

#### Default middlewares

Lennarb use two default middlewares: `Logging` and `ErrorHandling`.

- `Lenna::Middleware::Logging` - Colorized http request status.

```bash
❯ bundle exec puma ./config.ru                                                                                                 
Puma starting in single mode...                                                                                                
* Puma version: 6.4.0 (ruby 3.2.2-p53) ("The Eagle of Durango")                                                                
*  Min threads: 0                                                                                                              
*  Max threads: 5                                                                                                              
*  Environment: development                                                                                                    
*          PID: 88312                                                                                                          
* Listening on http://0.0.0.0:9292                             
Use Ctrl-C to stop             
[2023-11-29 14:06:08 -0300] "GET /" 200 0.19ms                                                                                 
[2023-11-29 14:06:11 -0300] "GET /" 200 0.10ms                                                                                 
[2023-11-29 14:06:11 -0300] "GET /" 200 0.20ms
```

- `Lenna::Middleware::ErrorHandling` - Error handling middleware in development mode.

<p align="center">
    <img src="https://drive.google.com/uc?export=view&id=1sKlHb49nWxBWSNQtaTwzF8wVUaCmdJCT" width="500">
</p>

### Render HTML templates

Lennarb allows you to render HTML templates using the `render` method on the response object. The `render` method takes two arguments: the name of the template file, and a hash of variables to pass to the template.

```rb
app.get('/hello') do |_req, res|
    res.render('hello', locals: { name: 'World' })
end
```

The example above renders the `hello.html.erb` template, passing the `name` variable to the template.
By default, Lennarb looks for templates in the `views` directory in root path. You can change this specifying the path for `views` in render method. Ex.

```rb
app.get('/hello') do |_req, res|
    res.render('hello', path: 'app/web/templates', locals: { name: 'World' })
end
```

### Render JSON

Lennarb allows you to render JSON using the `json` method on the response object. The `json` method takes one argument: the object to render as JSON.

```rb
app.get('/hello') do |_req, res|
    res.json(data: { message: 'Hello World!' })
end
```

The example above renders the `{ message: 'Hello World!' }` object as JSON.

### TODO

- [ ] Add support for mime types
- [ ] Add support for streaming
- [ ] Add support for CSRF
- [ ] Add support for SSL
- [ ] Add support for HTTP/2
- [ ] Add support for HTTP/3

## Development

To set up the development environment after cloning the repo, run:
    
```bash
$ bin/setup
```

To run the tests, run:

```bash
$ rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aristotelesbr/lennarb.
