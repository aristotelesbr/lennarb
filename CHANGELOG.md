# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.6] - 2023-29-11

### Changed

- Add default middlewares to `Lennarb::Router` class. Now, the `Lennarb::Router` class has the following middlewares by default:
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

