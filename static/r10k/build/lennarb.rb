# frozen_string_literal: true

lennarb_routes =
  lambda do |f, level, prefix, calc_path, lvars|
    base = BASE_ROUTE.dup
    ROUTES_PER_LEVEL.times do
      route = "#{prefix}#{base}"
      if level == 1
        params = lvars.map { |lvar| "\#{req.params[:#{lvar}]}" }
 .join('-')
        f.puts "  app.get '#{route}/:#{lvars.last}' do |req, res|"
        f.puts "    body = \"#{calc_path[1..]}#{base}-#{params}\""
        f.puts '    res.html body'
        f.puts '  end'
      else
        lennarb_routes.call(
          f,
          level - 1,
          "#{route}/:#{lvars.last}/",
          "#{calc_path}#{base}/",
          lvars + [lvars.last.succ]
        )
      end
      base.succ!
    end
  end

File.open("#{File.dirname(__FILE__)}/../apps/lennarb_#{LEVELS}_#{ROUTES_PER_LEVEL}.rb", 'wb') do |f|
  f.puts '# frozen_string_literal: true'
  f.puts "require 'lennarb'"
  f.puts 'app = Lennarb.new'
  lennarb_routes.call(f, LEVELS, '/', '/', ['a'])
  f.puts 'App = app.freeze'
end
