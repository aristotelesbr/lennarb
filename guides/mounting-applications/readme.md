## Mounting Applications

You can mount other applications at specific paths using the `mount` method. The component to be mounted must be a subclass of `Lennarb::App`.

```ruby
class Blog < Lennarb::App
  get "/" do |req, res|
    res.html("<h1>Welcome to my blog</h1>")
  end
end

class Admin < Lennarb::App
  get "/" do |req, res|
    res.html("<h1>Admin Dashboard</h1>")
  end
end

class Application < Lennarb::Base
  mount(Blog, at: "/blog")
  mount(Admin, at: "/admin")
end
```

## Middleware Configuration

Middleware can be configured at both the base application level and within individual mounted applications. This allows for flexible and modular application design.

```ruby
class Blog < Lennarb::App
  middleware do
    use MyCustomMiddleware
  end
end
```

## Conclusion

By using the `Base` class and the `mount` method, Lennarb provides a powerful way to structure your applications into modular components, each with its own routes and middleware.
