# Lennarb

Lennarb is a lightweight, fast, and modular web framework for Ruby based on Rack.

## Usage

### Basic Usage

To use Lennarb is very simple, just create a instance of `Lennarb` and use the methods `get`, `post`, `put`, `patch` etc..

```rb
app = Lennarb.new

app.get("/hello/:name") do |req, res|
	res.html("Hello #{params[:name]}")
end
```

Please see the [project documentation](https://aristotelesbr.github.io/lennarb) for more details.

  - [Getting Started](https://aristotelesbr.github.io/lennarbguides/getting-started/index) - This guide show you how to use the `lennarb`

  - [Middlewares](https://aristotelesbr.github.io/lennarbguides/middlewares/index) - This guide shows how to use middlewares in Lennarb.

  - [Namespace routes](https://aristotelesbr.github.io/lennarbguides/namespace-routes/index) - This guide show you how to use namespace routes.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
