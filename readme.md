# Lennarb

Lennarb is a lightweight, fast, and modular web framework for Ruby based on Rack. The **Lennarb**	supports Ruby (MRI) 3.0+

## Usage

To use Lennarb is very simple, just create a instance of `Lennarb` and use the methods `get`, `post`, `put`, `patch` etc..

```rb
app = Lennarb.new

app.get("/hello/:name") do |req, res|
	res.html("Hello #{params[:name]}")
end
```

## Performance

The **Lennarb** is very fast. The following benchmarks were performed on a MacBook Pro (Retina, 13-inch, Early 2013) with 2,7 GHz Intel Core i7 and 8 GB 1867 MHz DDR3. Based on [jeremyevans/r10k](https://github.com/jeremyevans/r10k) using the following [template build](static/r10k/build/lennarb.rb).

### Requests per second (RPS) - Dinamic routes

<p>
  <img src="static/rps.png" alt="Benchmarks" width="100%">
</p>

### Memory usage

<p>
	<img src="static/memory.png" alt="Benchmarks" width="100%">
</p>

### Runtime startup

<p>
	<img src="static/runtime_with_startup.png" alt="Benchmarks" width="100%">
</p>

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
