SampleApp = Lennarb::App.new do
  self.root = Pathname(__dir__)

  routes do
    get "/" do |req, res|
      res.status = 200
      res.html("Root path")
    end

    get "/hello" do |req, res|
      res.status = 200
      res.json({message: "Hello World"}.to_json)
    end
  end
end

SampleApp.initialize!
