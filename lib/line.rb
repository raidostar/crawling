class Line
  require 'capybara'
  require 'capybara/poltergeist'
  require 'selenium-webdriver'
  require 'mechanize'
  require 'rest-client'
  require 'csv'

  DEFAULT_HEADERS = {
    'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
    'Accept': "text/html,application/xhtml+xml,application/xml;q=0.9,imgwebp,*/*;q=0.8"
  }.freeze
  DEFAULT_SLEEP = 8.freeze

  # Poltergeist
  def initialize(option = {})
    %w(id password).each do |arg|
      instance_variable_set('@' + arg, options[arg.to_sym])
      raise "#{arg} is not set" unless options[arg.to_sym]
    end
    @session = nil
    @cookie = nil
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'] })
    end
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist
    Capybara.default_max_wait_time = 3
  end

  def daily_report
    obtain_login_cookie
  end

  private

  def obtain_login_cookie
    @session = Capybara::Session.new(:poltergeist)
    login
  end

  def export_cookies
    output = {}
    cookies = @session.driver.cookies
    cookies.each do |k,v|
      output[k.to_sym] = v.instance_variable_get(:@attributes)['value']
    end
    return output
  end

  def login
    action do
      @session.visit("https://account.line.biz/login?redirectUri=https%3A%2F%2Fadmanager.line.biz&status=success")
      sleep DEFAULT_SLEEP / 2

      agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/a').click

      element1 = agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/form/div/div[1]/input')
      element1.send_keys(ENV["LINE_ACCOUNT"])

      element2 = agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/form/div/div[2]/input')
      element2.send_keys(ENV["LINE_PASSWORD"])

      element3 = agent.find(:xpath, "//button[@type='submit']")
      element3.click
    end
  end

  def action
    yield if block_given?
    sleep DEFAULT_SLEEP
  end

  agent.visit("https://admanager.line.biz/adaccount/")
  sleep DEFAULT_SLEEP / 4

  test1 = agent.find(:xpath, "//*[@id='main']/div/div[2]/div[2]/table/thead/tr").text
  array_col = test1.split("\n")
  @test2 = agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody").text
  array_tbody = @test2.split("\n")

  @col_num = array_col.size
  td_num = array_tbody.size
  @tr_num = td_num / @col_num

  @array_tr = []
  for i in 1..@tr_num
    @array_tr[i-1] = agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]").text
  end

end