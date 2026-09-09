# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.5.1] - 2026-09-09

A patch release. No public API was added; everything here is a defect fix.

### Fixed

- `Lennarb::Request#content_type` and `#content_length` now read the Rack
  `CONTENT_TYPE` and `CONTENT_LENGTH` headers instead of the `HTTP_`-prefixed
  names. `Request#json?` was never true and `#json_body` never parsed on a real
  HTTP request.
- Exceptions raised inside a route handler no longer escape to Rack. They are
  logged and answered with a 500, except in development, where they are
  re-raised so `Rack::ShowExceptions` can render the backtrace.
- `app` inside a route handler no longer raises `SystemStackError`. The context
  object defined `app` with a block whose `self` was rebound to the context, so
  the call recursed into itself. Nothing had exercised it.
- `App#initialize!` no longer freezes the class-level routes. Each booted
  instance holds its own deep, frozen snapshot, so registering a route after the
  first boot works again -- it previously raised `RoutesFrozenError` and broke
  test suites and development reload.
- `Routes#freeze` now freezes the whole route tree rather than only its root.
- Environment-scoped configuration at the class level -- `config(:production) do
  ... end` inside a `Lennarb::App` subclass -- no longer raises `NameError`. The
  class-level `config` referenced an `env` that only exists on instances, so only
  the unscoped form worked. The instance and `Lennarb::Base` forms were
  unaffected.
- The test suite runs green again. minitest 6 extracted `Minitest::Mock` and
  `Object#stub` into the separate `minitest-mock` gem, which is now a
  development dependency. Both are pinned to their major, so a future major
  bump has to be a deliberate change rather than the result of a fresh resolve.
- Tests no longer leak `LENNA_ENV`/`APP_ENV`/`RACK_ENV` between each other,
  which made results depend on minitest's random seed.
- `Request#host` no longer shadows `Rack::Request#host` with a worse version. It
  returned the raw `Host` header, so it kept the port (`example.com:3000`) and
  returned `nil` when there was no `Host` header instead of falling back to
  `SERVER_NAME`. The override is removed and Rack's implementation applies.
- `Lennarb::Environment` equality is fixed in three ways. Two environments with
  the same name were not `==` to each other; `equal?` was aliased to `==`, which
  broke Ruby's object-identity contract in both directions (`env.equal?(env)` was
  false and `env.equal?(:test)` was true); and `eql?` was inconsistent with
  `hash`, so an environment did not work as a Hash key. `equal?` is no longer
  overridden, and `eql?`/`hash` are now consistent.
- 22 YARD `@retrn` typos corrected to `@return` in `route_node.rb`,
  `middleware_stack.rb`, `environment.rb` and `response.rb`. The tag was not
  recognised, so those return types were missing from the published
  documentation.
- The comments on `DuplicateRouteError`, `MissingEnvironmentVariable`,
  `MissingCallable` and `RoutesFrozenError` all claimed the error was raised
  when the app is initialized more than once. Each now describes what it is.
- **Route parameters are now URL-decoded.** `/u/John%20Doe` used to yield
  `"John%20Doe"`; it now yields `"John Doe"`, and a percent-encoded slash stays
  inside its segment instead of splitting the path. **If your application worked
  around this by decoding route parameters itself, remove that workaround or you
  will decode twice.** Segments are decoded with `Rack::Utils.unescape_path`, so
  `+` is left alone, as it should be in a path.
- `.gitignore` now matches `.minitestfailures`.

### Security

- **`ParameterFilter` matching is now case-insensitive.** It was built with a
  case-sensitive `Regexp.union`, and `RequestLogger` is in the default
  middleware stack in every environment and logs `request.params` at `info`. A
  form field named `Password`, `Token` or `API_KEY` was written to the log in
  cleartext, and from there to journald, CloudWatch or Datadog.
- **`Regexp` filters passed to `ParameterFilter` now work.** The docstring
  documented them, but `filters.map(&:to_s)` stringified them and
  `Regexp.union` escaped the result, so the filter matched only the literal text
  `(?i-mx:password)`. Passing a Regexp to harden filtering disabled it entirely,
  including for keys that had previously been filtered.
- **The default filter list now covers** `auth`, `credit`, `card_number`, `cvn`,
  `iban`, `api`, `pin` and `session_id`. Previously `cvv` was filtered while
  `card_number` was not, protecting the CVV and not the card number it guards.
- **`ParameterFilter#filter` no longer modifies the parameters it is given.**
  `params.dup` is shallow and nested values were assigned in place, so an app
  calling `filter(req.params)` for an error report found its own params replaced
  by `"[FILTERED]"`.
- **`RequestLogger` now uses the logger configured on the app handling the
  request**, resolved from the Rack env. It read `Lennarb::App.app.config.logger`,
  and `App.app` is never assigned anywhere, so a configured logger was
  unreachable and request lines always went to the process's stderr. Configuring
  a redacting or file-scoped logger was therefore not an available mitigation.
- **The request path is escaped before being logged.** Control characters from
  the client could otherwise forge log lines. Parameter values were already safe
  because they go through `inspect`.
- **Booting without `LENNA_ENV`, `APP_ENV` or `RACK_ENV` now logs a warning.**
  The environment defaults to `development`, which enables
  `Rack::ShowExceptions`; a deployment that forgot to export the variable served
  the entire Rack environment, `Authorization` and `Cookie` included, to anyone
  who could trigger a 500. Changing the default itself is a breaking change and
  is deferred to 1.6.0.
- **`Response#json` no longer echoes the exception message to the client**, which
  could carry `inspect` output of the object being serialized, and now rescues
  `JSON::JSONError` rather than `JSON::GeneratorError`: a circular or over-deep
  object graph raises `JSON::NestingError`, which descends from `ParserError` and
  escaped the rescue entirely.

### Changed

- `RequestHandler` compiles the route execution context once per application
  class instead of building an object with a fresh singleton class on every
  request. On ruby 3.4.1 (arm64-darwin23): static route 424,302 to 753,914
  req/s, dynamic route 175,364 to 221,795 req/s, `create_context` 1.37us to
  0.15us (24% to 3.3% of a request), 48 to 40 objects allocated per request.
  The extra object over the 39 measured mid-release is the cost of decoding
  route parameters, below.
- `App#routes` returns the instance's frozen snapshot after `initialize!`, so
  `app.routes.equal?(App.routes)` is no longer true once the app is booted.
- Documentation now teaches subclassing `Lennarb::App` as the canonical form.
  The previous quick start raised `NoMethodError`, and subclassing is the only
  form isolated per application. The pt-BR quick start also called `configure`
  (the method is `config`) and `mandary` (a typo for `mandatory`).
- Changelog no longer references `Lennarb::Application` or
  `Lennarb::Routes::Mixin`, neither of which exists. The real APIs are
  `Lennarb::Base` and `Lennarb::Base.mount`.

### Added

- `benchmark/hot_path.rb`, so the performance claims can be reproduced.
- `required_ruby_version = ">= 3.4"` in the gemspec. The code uses `it`, the
  implicit block parameter introduced in Ruby 3.4, and the README has always
  promised 3.4+, but no version constraint was declared. RubyGems would install
  the gem on an older Ruby and the first `require` failed with a `SyntaxError`
  rather than a clear resolution error. This has been missing since 0.1.0.

### Known limitations

- Two applications created with `Lennarb::App.new` without subclassing still
  share the class's route definitions. Subclass to isolate them.
- Hooks and helpers are still stored per app class and are shared the same way.
  Tracked in [#87](https://github.com/aristotelesbr/lennarb/issues/87); they are
  meant to become an opt-in mechanism rather than machinery every application
  carries.

## [1.5.0] - 2025-04-19

### Added

- Add `Lennarb::Base` class to be the base class of the "standard" implementation of the Lennarb framework, for mounting several applications behind one middleware stack.
- Add middleware support to Lennarb::App class.
- Add `middleware` support to `Lennarb::Base` with default middlewares.
- Add files to centralize the errors of the project.
- Add CODE_OF_CONDUCT.md in English and Portuguese
- Add CONTRIBUTING.md in English and Portuguese
- Add `Lennarb::Logger` class for structured logging with support for tags and colorization
- Add logger dependency to enhance logging capabilities in the framework
- Add `Lennarb::ParameterFilter` for sensitive parameter filtering in logs and exceptions
- Add `Lennarb::RequestLogger` middleware for detailed HTTP request logging
- Add `Lennarb::Hooks` module for implementing hooks in the framework
- Add improved request handling and configuration options
- Add `RoutesFrozenError` for improved route modification handling
- Add support for defining helpers with both modules and blocks in `Lennarb::App`.
- Add `Lennarb::Helpers.define` method to handle modules and blocks for helper definitions.
- Add tests for `Lennarb::Helpers` to validate module inclusion and block evaluation.
- Add `Lennarb::Hooks` tests to validate hook initialization, addition, and execution.

### Changed

- Lennarb Logo
- Migrate from utopiaproject to yard for documentation
- Fix logo SVG display in yard documentation
- Restructure App class to enhance routing, middleware, and initialization processes
- Simplify Routes class by removing unnecessary comments and enhancing route definitions
- Introduce Helpers module for managing application-specific helper methods
- Update logger tag to use symbol for consistency
- Enhance logging functionality with improved request logging details
- Simplify config method by removing block parameter and improving readability
- Update `Lennarb::App.helpers` to accept a module or block for defining helpers.

### Fixed

- Fix typo in require_relative statement for constants file
- Fix conditional debug dependency based on Ruby engine

## [1.4.1] - 2025-02-23

### Added

- Add support to mount routes. Now, you can centralize the routes in a single file and mount them in the main application. Ex.

```rb
class Posts < Lennarb::App
  get '/posts' do |req, res|
    res.html('Posts')
  end
end

class Application < Lennarb::Base
  mount Posts, at: '/'
end
```

`Lennarb::Base.mount` registers a `Lennarb::App` subclass at a path, behind the
base application's middleware stack. Call it once per application you want to
mount.

- Add `Lennarb::Environment` module to manage the environment variables in the project. Now, the `Lennarb` class is the main class of the project.
- Add `Lennarb::Config` module to manage the configuration in the project. Now, the `Lennarb` class is the main class of the project.
- Add `Lennarb::App` class.
- Lint the code with `standard` gem on the CI/CD pipeline.

### Changed

- Convert the `Lennarb` class to a module. Now, the `App` class is the main class of the project.
- Move the request process to `Lennarb::RequestHandler` class.
- Improve the method `merge!` from `Lennarb::RouterNode` to prevent the duplication of the routes.

### Fixed

- Software design issues.

## [1.4.0] - 2025-02-09

### Changed

- The `freeze!` method was removed from the `Lennarb` class. Use `initializer!` to build and freeze the application.

```rb
# app.rb

require 'lennarb'

MyApp = Lennarb.new do |router|
  router.get '/hello' do |req, res|
    res.html('Hello World')
  end
end

MyApp.initializer!

run MyApp
```

### Remove

- Removes bake scripts from the project. Use `rack'` to run tasks.
- Removes `plugin` module and basic plugins from the project. Now, the `Lennarb` class is the main class of the project.
- Removes unnecessary tests.
- Removes `.rubocop.yml` file from the project. Now, the project uses the default configuration of the `standard` gem.

### Added

- Add `simplecov` gem to generate the test coverage report.
- Add `m` gem to run the tests.

## [1.3.0] - 2024-11-21

### Added

- Add `Lennarb::Plugin` module to manage the plugins in the project. Now, the `Lennarb` class is the main class of the project.

- Automatically loads plugins from the default directory

- Supports custom plugin directories via `LENNARB_PLUGINS_PATH`

- Configurable through environment variables

### Changed

- Change the `finish` method from `Lennarb` class to call `halt(@res.finish)` method to finish the response.

### Removed

- Remove `Lennarb::ApplicationBase` class from the project. Now, the `Lennarb` class is the main class of the project.

## [0.6.1] - 2024-05-17

### Added

- Add `Lennarb::Plugin` module to manage the plugins in the project. Now, the `Lennarb` class is the main class of the project.
- Add `Lennarb::Plugin::Base` class to be the base class of the plugins in the project.
- Add simple guide to use `Lenn` plugins. See [guides/plugins/readme.md](guides/plugins/readme.md) for more details.

## [0.4.4] - 2024-04-02

### Added

- Add `Lennarb::Router` module to manage the routes in the project. Now, the `Lennarb` class is the main class of the project.

## [0.4.3] - 2024-04-01

### Added

### Remove

- Remove `Lennarb::ApplicationBase` class from the project. Now, the `Lennarb` class is the main class of the project.

### Changed

- Improve performance of the RPS (Requests per second), memory and CPU usage.
- Change the `finish` method from `Lennarb` class to call `halt(@res.finish)` method to finish the response.

## [0.4.2] - 2024-08-02

### Added

- Add `header` and `options` methods to `Lennarb` and `Lennarb::ApplicatiobBase`.

### Fix

- Fix Content-Length header to be the length of the body in the response.

## [0.4.1] - 2024-08-02

### Change

- Change behavior of `Lennarb::ApplicationBase` class to be the base class of the `Lennarb` class. Now, the `Lennarb` class is a subclass of `Lennarb::ApplicationBase` class.

That permits to create a new application with the `Lennarb::ApplicationBase` class and use http methods to create the routes. Ex.

```rb
# app.rb

require 'lennarb'

class MyApp < Lennarb::ApplicationBase
 get '/hello' do |req, res|
  res.html('Hello World')
 end
end
```

### Removed

- Remove `Lennarb::Application` module from the project. Now, the `Lennarb` class is the main class of the project.

## [0.4.0] - 2024-07-02

### Added

- Add `Lennarb::ApplicationBase` class to be the base class of the `Lennarb` class. Now, the `Lennarb` class is a subclass of `Lennarb::ApplicationBase` class.

That permits to create a new application with the `Lennarb::ApplicationBase` class and use http methods to create the routes. Ex.

```rb
# app.rb

require 'lennarb'

class MyApp
  include Lennarb::ApplicationBase

 get '/hello' do |req, res|
  res.html('Hello World')
 end
end
```

### Change

- Change the test/test_lenna.rb to test/test_lennarb.rb
- Change `add_route` method from `Lennarb` class to `__add_route` and remove from private section.

## [0.2.0] - 2024-08-01

### Removed

- Remove `zeitwerk` gem to load the files in the project.
- Remove `console` gem to print the logs in the console.
- Remove `Lenna` module. Now, the `Lennarb` class is the main class of the project.
- Remove `Middleware` module.
- Remove `CLI` module.
- Remove `Cache` module

### Changed

- Change `Lennarb::Application` class to `Lennarb` class.
- Request class and Response class now are in `Lennarb` class
- Change `Lennarb::Router` class to `Lennarb` class

### Fixed

- Improve performance of the RPS (Requests per second), memory and CPU usage. Now the performance is similar to the [Roda](https://github.com/jeremyevans/roda/tree/master).

## [0.1.7] - 2023-23-12

### Added

- Add `console` gem to print the logs in the console.

- Add CLI module to:

  - Create a new project with `lennarb new` command.
  - Run the server with `lennarb server` command.

- Add simple guide to create and run a project with Lennarb. See [guides/command-line/readme.md](guides/command-line/readme.md) for more details.

- Add `Reload` middleware to reload the application in development environment. You can import and use this middleware in your application. Ex.

```rb
# app.rb

require 'lenna/middleware/default/reload'

app = Lenna::Application.new

app.use Lenna::Middleware::Default::Reload
```

In the next version, this middleware will be available by default in development environment.

- Add `root` method to `Lennarb` module to get the root path of the project. Ex.

```rb
# app.rb

Lennarb.root.join('app.rb')
# => /home/user/project/app.rb
```

- Add `zeitwerk` gem to load the files in the project.

### Remove

- Remove `Logging` and `ErrorHandling` middlewares from any environment. Now, theses middlewares are only available in development environment.

### Changed

- Change log level to `fatal` in test environment.

## [0.1.6] - 2023-21-12

### Changed

- Update `README.md` with the new features. Move examples to `guides` folder.
- Replace `rubocop` to `standard` gem to lint the code.
- Move `puma` gem to development dependencies.
- Use tabs instead of spaces to indent the code.
- Add default middlewares to `Lennarb::Router` class. Now, the `Lennarb::Router` class has the following middlewares by default:

  - `Lennarb::Middleware::Default::Logging`
  - `Lennarb::Middleware::Default::ErrorHandling`

- Replace `assign_status` to `=` on Response

```rb
response.status = 200
```

- Rename `Lenna::Base` to `Lenna::Application` and accept a block to build the routes. Ex.

```rb
Lenna::Application.new do |app|
    app.get '/hello' do |req, res|
        res.status = 200
        res['Content-Type'] = 'text/plain'
        res.body = 'Hello World'
    end
    app.post '/hello' do |req, res|
        res.status = 200
        res['Content-Type'] = 'text/plain'
        res.body = 'Hello World'
    end
end
```

- The Middleware app now implements [Singleton](https://ruby-doc.org/stdlib-2.5.1/libdoc/singleton/rdoc/Singleton.html) pattern to manager state.

### Added

- Add `standard` gem to lint the code.
- Add `maintenance` gropu to `Gemfile` with:
  - Add `bake-gem` gem to run the tasks.
  - Add `bake-modernize` gem to update the code to the latest Ruby version.
  - Add `utopia-project` gem to generate the project.
  - Add `bake-github-pages` to generate the GitHub Pages.
- Add `bake` gem to run the tasks.
- Add `puma` gem to run the development server.
- Add alias to `assign_header` to `[]=` on Response. Now, you can use:

```rb
response['Content-Type'] = 'application/json'
```

- Add alias to `assign_body` to `:body=` on Response. Now, you can use:

```rb
response.body = 'Hello World'
```

- Add alias to `assign_params` to `:params=` on Request. Now, you can use:

```rb
request.params = { name: 'John' }
```

### Removed

- Remove `listen` method to run development server. Now, you must be use `.config.ru` file to run the development server. Ex.

```rb
# .config.ru

require 'lennarb'

app = Lennarb::Application.new do |app|
  app.get '/hello' do |req, res|
    res.status = 200
    res['Content-Type'] = 'text/plain'
    res.body = 'Hello World'
  end
  app.post '/hello' do |req, res|
    res.status = 200
    res['Content-Type'] = 'text/plain'
    res.body = 'Hello World'
  end
end

run app
```

- Remove Rakefile. Now, you must be use `bake` gem to run the tasks. Ex.

```sh
bundle exec bake test
```

## Bug Fixes

- Fix default middlewares to `Lennarb::Router` class. Now, the `Lennarb::Router` class has the following middlewares by default:
  - `Lennarb::Middleware::Default::Logging`
  - `Lennarb::Middleware::Default::ErrorHandling`

## [0.1.5] - 2023-25-11

### Added

- Add `assign_params` method to Request class

## [0.1.4] - 2023-25-11

### Fixed

- Internal docmentation methods
- Fix `post_params` from Resquest router class

### Added

- Add basic documentation for usage. See [README.md](README.md) for more details.

## [0.1.3] - 2023-24-11

## [0.1.2] - 2023-23-11

### Added

- Implemented a specific error handler for Content-Type related errors, enhancing the system's ability to respond appropriately based on whether the request Content-Type is JSON or HTML.

### Removed

- Removed the debug gem from development dependencies, streamlining the development environment setup.

### Fixed

- Fixed a bug that prevented the correct reading of the Content-Type header in requests, ensuring proper handling of content types.

## [0.1.1] - 2023-23-11

### Added

- Introduced `Array.wrap` extension to the `Array` class for more reliable conversion of objects to arrays within the Lennarb router environment. This method ensures consistent array wrapping of single objects and `nil` values.

### Changed

- Refactored the `put_header` method to use the `Array.wrap` method for more predictable header value handling.
- Renamed methods to have a consistent `assign_` prefix to standardize the API interface:
  - `put_header` to `assign_header`
  - `write_body` to `assign_body`
  - `set_params` to `assign_params`
  - `update_status` to `assign_status`

### Deprecated

### Removed

### Fixed

### Security
