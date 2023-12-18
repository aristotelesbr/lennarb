# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.7] - 2023-30-11

### Changed

- Update `README.md` with the new features. Move examples to `guides` folder.
- Replace `rubocop` to `standard` gem to lint the code.
- Move `puma` gem to development dependencies.
- Use tabs instead of spaces to indent the code.

### Added

- Add `standard` gem to lint the code.
- Add `maintenance` gropu to `Gemfile` with:
	- Add `bake-gem` gem to run the tasks.
	- Add `bake-modernize` gem to update the code to the latest Ruby version.
	- Add `utopia-project` gem to generate the project.
	- Add `bake-github-pages` to generate the GitHub Pages.

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


## [0.1.6] - 2023-29-11

### Changed

- Add default middlewares to `Lennarb::Router` class. Now, the `Lennarb::Router` class has the following middlewares by default:
  - `Lennarb::Middleware::Default::Logging`
  - `Lennarb::Middleware::Default::ErrorHandling`

### Changed

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

