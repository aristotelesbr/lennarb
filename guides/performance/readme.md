# Performance

The **Lennarb** is very fast. The following benchmarks were performed on a MacBook Pro (Retina, 13-inch, Early 2013) with 2,7 GHz Intel Core i7 and 8 GB 1867 MHz DDR3. Based on [jeremyevans/r10k](https://github.com/jeremyevans/r10k) using the following [template build](static/r10k/build/lennarb.rb).

All tests are performed using the **Ruby 3.3.0**

### Requests per second (RPS) - Dinamic routes

![Benchmarks](static/rps.png)

### Memory usage

![Benchmarks](static/memory.png)

### Runtime startup

![Benchmarks](static/runtime.png)

## Best numbers

| Framework  | RPS | Memory usage | Runtime startup |
| ---------- | --- | ------------ | --------------- |
| Lennarb    | 1   | 1            | 1               |
| Roda       | 2   | 2            | 2               |
| Syro       | 3   | 3            | 3               |
| Hanami-API | 5   | 5            | 5               |
| Sinatra    | 6   | 6            | 6               |
| Rails      | 7   | 6            | 6               |

## Conclusion

These numbers are just a small reference, **Lennarb** is not a framework, it is a router. In my opinion, **Roda** is the best router for Ruby because it has many interesting features, such as a middleware manager, and very good development performance.

