# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add `Lennarb::Environment` module to manage the environment variables in the project. Now, the `Lennarb` class is the main class of the project.
- Add `Lennarb::Config` module to manage the configuration in the project. Now, the `Lennarb` class is the main class of the project.
- Add `Lennarb::App` class.

### Changed

- Convert the `Lennarb` class to a module. Now, the `App` class is the main class of the project.
- Move the request process to `Lennarb::RequestHandler` class.

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
