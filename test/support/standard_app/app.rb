StandardApp = Lennarb::Application.new do
  self.root = Pathname(__dir__)

  routes do
    get "/" do |req, res|
      res.html("Root path")
    end

    get "/hello" do |req, res|
      res.json({message: "Hello World"})
    end
  end
end

StandardApp.initialize!
