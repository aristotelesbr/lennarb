# Sample application for testing
# This creates a single instance with routes defined before initialization
SampleApp = Lennarb::App.new do
  self.root = Pathname(__dir__)

  # This will work with our updated implementation
  # The block is evaluated in the context of the class
  routes do
    get "/" do |req, res|
      res.html("Root path")
    end

    get "/hello" do |req, res|
      res.json({message: "Hello World"})
    end

    get "/api" do |req, res|
      res.json({action: "index"})
    end

    post "/api" do |req, res|
      res.json({action: "create"})
    end

    get "/users/:id" do |req, res|
      res.json({id: req.params[:id]})
    end

    get "/error" do |_, _|
      raise Lennarb::Error
    end
  end
end

# Initialize the app after defining all routes
SampleApp.initialize!
