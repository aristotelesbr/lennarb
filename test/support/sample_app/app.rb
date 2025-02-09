SampleApp = Lennarb.new do |router|
  router.get "/" do |req, res|
    res.status = 200
    res.html("Root path")
  end
  router.get "hello" do |req, res|
    res.status = 200
    res.json({message: "Hello World"}.to_json)
  end
end
