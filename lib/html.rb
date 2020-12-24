class Html
	require 'capybara'
  require 'capybara/poltergeist'
  require 'selenium-webdriver'

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, { js_errors: false, timeout: 1000 } )
  end
  Capybara.run_server = false
  Capybara.default_driver = :poltergeist
  Capybara.default_max_wait_time = 3

  @session = Capybara::Session.new(:poltergeist)
  
  @session.visit("https://navivi.site/archives/89682")
  sleep 2
  source = @session.find('body')['innerHTML']
  source = source.gsub('><', ">\n<") + "\n"
  filename = 'navivi_' + @session.current_path.gsub('/archives/','') + '.html'
  
  header_file = "header.html"
  design_file = "navivi_common.html"
  end_file = "end.html"

  hfile = File.new(header_file, 'r')
  hsize = hfile.stat.size

  dfile = File.new(design_file, 'r')
  dsize = dfile.stat.size

  efile = File.new(end_file, 'r')
  esize = efile.stat.size

  if hfile && dfile && efile
    @header = hfile.sysread(hsize)
    @style = dfile.sysread(dsize)
    @end = efile.sysread(esize)
  else
    puts "Unable to read!"
  end

  wfile = File.new(filename, 'a')
  if wfile
    wfile.syswrite(@header)
    wfile.syswrite(@style)
    wfile.syswrite(source)
    wfile.syswrite(@end)
  else
    puts "unable to write!"
  end
end