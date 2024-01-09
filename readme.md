# Lennarb

Lennarb is a lightweight, fast, and modular web framework for Ruby based on Rack. The **Lennarb** supports Ruby (MRI) 3.0+

## Usage

To use Lennarb is very simple, just create a instance of `Lennarb` and use the methods `get`, `post`, `put`, `patch` etc..

```rb
app = Lennarb.new

app.get("/hello/:name") do |req, res|
  name = req.params[:name]

  res.html("Hello #{name}")
end
```

To more examples of usage see [getting started](https://aristotelesbr.github.io/lennarbguides/getting-started/index) documentation.

## Performance

### Requests per second (RPS) - Dinamic routes

![Benchmarks](static/rps.png)

To more details about the benchmarks, please see the [project documentation](https://aristotelesbr.github.io/lennarb/performance/index).

## Documentation

Please see the [project documentation](https://aristotelesbr.github.io/lennarb) for more details.

- [Getting Started](https://aristotelesbr.github.io/lennarbguides/getting-started/index) - This guide show you how to use the `lennarb`

- [Response](https://aristotelesbr.github.io/lennarbguides/response/index) - This guide show you how to use the Response object

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
