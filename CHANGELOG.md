# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Released]

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

