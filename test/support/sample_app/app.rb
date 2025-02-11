SampleApp = Lennarb::App.new do |router|
  self.root = Pathname(__dir__)

  router.get "/" do |req, res|
    res.status = 200
    res.html("Root path")
  end
  router.get "hello" do |req, res|
    res.status = 200
    res.json({message: "Hello World"}.to_json)
  end
end

SampleApp.initialize!
