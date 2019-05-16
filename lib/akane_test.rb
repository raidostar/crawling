class Akane_Test
  require 'capybara'
  require 'capybara/poltergeist'
  require 'selenium-webdriver'
  require 'rest-client'
  require 'csv'

  agent = Selenium::WebDriver.for :chrome

  DEFAULT_HEADERS = {
    'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
    'Accept-Language': 'ja'
  }.freeze
  DEFAULT_SLEEP = 3.freeze

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

  @session = Capybara::Session.new(:poltergeist)
  @test_page = @session.visit "https://www.akane-ad.com/agent/login"
  DEFAULT_SLEEP = 3.freeze
  @session.find('#login_id').set(ENV["GOOGLE_ACCOUNT"])
  @session.find('#password').set(ENV["GOOGLE_PASSWORD"])

  # @session.find(:xpath, "//input[@type='submit']").trigger('click')

  # DEFAULT_SLEEP = 3.freeze
  # agent = Selenium::WebDriver.for :chrome

  # @test_page = agent.get("https://accounts.google.com/signin/v2/identifier?hl=ja&passive=true&continue=https%3A%2F%2Fwww.google.com%2F%3Fgws_rd%3Dssl&flowName=GlifWebSignIn&flowEntry=ServiceLogin")

  # element1 = agent.find_element(:name, 'identifier')
  # element1.send_keys(ENV["GOOGLE_ACCOUNT"])
  # agent.find_element(:class, 'CwaK9').click
  # sleep 5.freeze

  # element3 = agent.find_element(:name, 'password')
  # element3.send_keys(ENV["GOOGLE_PASSWORD"])
  # sleep DEFAULT_SLEEP
  # element4 = agent.find_element(:id, 'passwordNext')
  # element4.click


  # # reCaptcha breaking for human in the google web store
  # sleep DEFAULT_SLEEP
  # agent.get("https://chrome.google.com/webstore/detail/buster-captcha-solver-for/mpbjkejclgfgadiemmefgebjfooflfhl/related")
  # sleep DEFAULT_SLEEP
  # begin
  #   element0 = agent.find_element(:xpath, '/html/body/div[4]/div[2]/div/div/div[2]/div[2]/div')
  # rescue
  #   element0 = agent.find_element(:xpath, '/html/body/div[4]/div[2]/div/div/div[1]/div[2]/div')
  # end
  # element0.click

  # # login to akane website
  # sleep DEFAULT_SLEEP
  # agent.get("https://www.akane-ad.com/agent/login")
  # sleep DEFAULT_SLEEP

  # wait = Selenium::WebDriver::Wait.new(timeout: 5)

  # wait.until{agent.find_element(name: 'login_id')}
  # element1 = agent.find_element(:name, 'login_id')
  # element1.send_keys('qdHU6aNKxys7DXRS')

  # wait.until{agent.find_element(name: 'password')}
  # element2 = agent.find_element(:name, 'password')
  # element2.send_keys('GexJKS8blOp2QFcH')

  # test_element = agent.find_element(:xpath, "//div[@id='mainTopLogin']/form/table/tbody/tr[3]/td/div")

  # wait.until{agent.find_element(xpath: "//iframe")}
  # element3 = agent.find_element(:xpath, "//iframe")
  # element3.click

  # client = AntiCaptcha.new
  # options ={
  #   website_key: '6LcYVV4UAAAAAB475UplzDhwiBkLq0NoCXdcz07d',
  #   website_url: ''
  # }

  # # Capybara.register_driver :poltergeist do |app|
  # #   Capybara::Poltergeist::Driver.new(app, js_errors: false)
  # # end

  # # Capybara.default_driver = :poltergeist
  # # Capybara.javascript_driver = :poltergeist
  # # Capybara.run_server = false
  # # Capybara.default_selector = :xpath
  # # page = Capybara.current_session
  # # page.visit("https://chrome.google.com/webstore/detail/buster-captcha-solver-for/mpbjkejclgfgadiemmefgebjfooflfhl/related")
  # # @page_all = page.text

  # agent.get("https://www.akane-ad.com/agent/login")
  # sleep DEFAULT_SLEEP

  # wait = Selenium::WebDriver::Wait.new(timeout: 5)

  # wait.until{agent.find_element(name: 'login_id')}
  # element1 = agent.find_element(:name, 'login_id')
  # element1.send_keys('qdHU6aNKxys7DXRS')

  # wait.until{agent.find_element(name: 'password')}
  # element2 = agent.find_element(:name, 'password')
  # element2.send_keys('GexJKS8blOp2QFcH')

  # wait.until{agent.find_element(xpath: "//iframe")}
  # element3 = agent.find_element(:xpath, "//iframe")
  # element3.click
  # sleep DEFAULT_SLEEP

  # element4 = agent.find_element(:xpath, "//*[@id='solver-button']")
  # element4.click
end