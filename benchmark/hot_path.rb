# Measures the per-request cost of the Lennarb request path.
#
# Run with:  bundle exec ruby benchmark/hot_path.rb
#
# Reports requests per second and objects allocated per request for a static
# and a dynamic route, plus the isolated cost of route matching and context
# creation, so a regression can be attributed rather than guessed at.

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "lennarb"
require "benchmark"
require "stringio"

class BenchApp < Lennarb::App
  get("/") { |req, res| res.text("ok") }
  get("/users/:id/posts/:post_id") { |req, res| res.text(req.params[:id]) }
end

def rack_env(path)
  {
    "REQUEST_METHOD" => "GET",
    "PATH_INFO" => path,
    "QUERY_STRING" => "",
    "SERVER_NAME" => "example.org",
    "SERVER_PORT" => "80",
    "rack.url_scheme" => "http",
    "rack.input" => StringIO.new
  }
end

def measure(label, iterations)
  elapsed = Benchmark.realtime { iterations.times { yield } }
  puts format("%-22s %9d req/s  %6.2f us/req", label, iterations / elapsed, elapsed / iterations * 1e6)
end

def allocations(iterations)
  GC.start
  before = GC.stat(:total_allocated_objects)
  iterations.times { yield }
  (GC.stat(:total_allocated_objects) - before) / iterations.to_f
end

app = BenchApp.new.initialize!
handler = Lennarb::RequestHandler.new(app)

ITERATIONS = 100_000
static = rack_env("/")
dynamic = rack_env("/users/42/posts/7")

2_000.times { handler.call(static.dup) }

puts "ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}), lennarb #{Lennarb::VERSION}"
puts

measure("static route", ITERATIONS) { handler.call(static.dup) }
measure("dynamic route", ITERATIONS) { handler.call(dynamic.dup) }
measure("match_route only", ITERATIONS) { app.routes.match_route(["users", "42", "posts", "7"], :GET) }
measure("create_context only", ITERATIONS) { handler.send(:create_context) }

puts
puts format("objects per request     %6.1f", allocations(10_000) { handler.call(dynamic.dup) })
