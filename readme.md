<div align="center">
  <picture>
    <img alt="Lennarb" src="logo/lennarb.svg" width="250">
  </picture>

---

A lightweight, fast, and modular web framework for Ruby based on Rack. The **Lennarb** supports Ruby (MRI) 3.4+

[![Test](https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml/badge.svg)](https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml)
[![Gem](https://img.shields.io/gem/v/lennarb.svg)](https://rubygems.org/gems/lennarb)
[![Gem](https://img.shields.io/gem/dt/lennarb.svg)](https://rubygems.org/gems/lennarb)
[![MIT License](https://img.shields.io/:License-MIT-blue.svg)](https://tldrlegal.com/license/mit-license)

</div>

## Basic Usage

```ruby
require "lennarb"

Lennarb::App.new do
  config do
    optional :env, string, "prodcution"
    optional :port, int, 9292
  end

  routes do
    get("/hello/:name") do |req, res|
      name = req.params[:name]
      res.html("Hello, #{name}!")
    end
  end
end
```

## Performance

### 1. Requests per Second (RPS)

![RPS](https://raw.githubusercontent.com/aristotelesbr/lennarb/main/benchmark/rps.png)

See all [graphs](https://github.com/aristotelesbr/lennarb/blob/main/benchmark)

| Position | Application | 10 RPS     | 100 RPS    | 1.000 RPS | 10.000 RPS |
| -------- | ----------- | ---------- | ---------- | --------- | ---------- |
| 1        | Lenna       | 126.252,36 | 108.086,55 | 87.111,91 | 68.460,64  |
| 2        | Roda        | 123.360,37 | 88.380,56  | 66.990,77 | 48.108,29  |
| 3        | Syro        | 114.105,38 | 80.909,39  | 61.415,86 | 46.639,81  |
| 4        | Hanami-API  | 68.089,18  | 52.851,88  | 40.801,78 | 27.996,00  |

This table ranks the routers by the number of requests they can process per second. Higher numbers indicate better performance.

Please see [Performance](https://aristotelesbr.github.io/lennarb/guides/performance/index.html) for more information.

## Usage

- [Getting Started](https://aristotelesbr.github.io/lennarb/guides/getting-started/index) - This guide covers getting up and running with **Lennarb**.

- [Performance](https://aristotelesbr.github.io/lennarb/guides/performance/index.html) - The **Lennarb** is very fast. The following benchmarks were performed on a MacBook Pro (Retina, 13-inch, Early 2013) with 2,7 GHz Intel Core i7 and 8 GB 1867 MHz DDR3. Based on [jeremyevans/r10k](https://github.com/jeremyevans/r10k) using the following [template build](static/r10k/build/lennarb.rb).

- [Request]() - TODO

- [Response](https://aristotelesbr.github.io/lennarb/guides/response/index.html) - This is the response guide.
  The `res` object is used to send a response to the client. The Lennarb use a custom response object to send responses to the client. The `res` object is an instance of `Lennarb::Response`.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
