class PostsController
  extend Lennarb::Routes::Mixin

  get "/posts" do |req, res|
    res.status = 200
    res.text("posts")
  end
end

