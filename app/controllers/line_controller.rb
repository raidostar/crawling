class LineController < ApplicationController
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
  DEFAULT_SLEEP = 3.freeze

  def index
    @session = nil
    @cookie = nil
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'] })
    end
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist
    Capybara.default_max_wait_time = 3

    agent = Capybara::Session.new(:poltergeist)
    agent.visit("https://account.line.biz/login?redirectUri=https%3A%2F%2Fadmanager.line.biz&status=success")
    agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/a').click

    element1 = agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/form/div/div[1]/input')
    element1.send_keys(ENV["LINE_ACCOUNT1"])
    sleep 1.freeze
    element1.send_keys(ENV["LINE_ACCOUNT2"])
    sleep 2.freeze
    element1.send_keys(ENV["LINE_ACCOUNT3"])

    sleep DEFAULT_SLEEP

    element2 = agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/form/div/div[2]/input')
    element2.send_keys(ENV["LINE_PASSWORD1"])
    sleep 1.freeze
    element2.send_keys(ENV["LINE_PASSWORD2"])
    sleep 2.freeze
    element2.send_keys(ENV["LINE_PASSWORD3"])

    element3 = agent.find(:xpath, "//button[@type='submit']")
    element3.click

    sleep 5.freeze

    agent.visit("https://admanager.line.biz/adaccount/")
    sleep DEFAULT_SLEEP

    @test1 = agent.find(:xpath, "//*[@id='main']/div/div[2]/div[2]/table/thead/tr").text
    array_col = @test1.split("\n")
    @test2 = agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody").text
    array_tbody = @test2.split("\n")

    @col_num = array_col.size
    td_num = array_tbody.size
    @tr_num = td_num / @col_num

    @array_tr = []
    for i in 1..@tr_num
      @array_tr[i-1] = agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]").text
    end

    #options = Selenium::WebDriver::Chrome::Options.new
    #options.add_argument("--headless")
    # agent = Selenium::WebDriver.for :chrome
    # agent.get("https://account.line.biz/login?redirectUri=https%3A%2F%2Fadmanager.line.biz&status=success")
    # agent.find_element(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/a').click

    # wait = Selenium::WebDriver::Wait.new(timeout: 5)
    # wait.until{agent.find_element(name: 'email')}
    # element1 = agent.find_element(:name, 'email')
    # element1.send_keys("k-iwata@fullout.jp")

    # sleep DEFAULT_SLEEP

    # wait.until{agent.find_element(name: 'password')}
    # element2 = agent.find_element(:name, 'password')
    # element2.send_keys("fullout01")

    # wait.until{agent.find_element(xpath: "//button[@type='submit']")}
    # element3 = agent.find_element(:xpath, "//button[@type='submit']")
    # element3.click

    # sleep 5.freeze

    # agent.get("https://admanager.line.biz/adaccount/")
    # sleep DEFAULT_SLEEP
    # @doc = agent.page_source
    # @test1 = agent.find_element(:xpath, "//*[@id='main']/div/div[2]/div[2]/table/thead/tr").text
    # array_col = @test1.split("\n")
    # @test2 = agent.find_element(:xpath, "//*[@id='main']/div/div[3]/table/tbody").text
    # array_tbody = @test2.split("\n")

    # col_num = array_col.size
    # td_num = array_tbody.size
    # @tr_num = td_num / col_num

    # @array_tr = []
    # for i in 1..@tr_num
    #   @array_tr[i-1] = agent.find_element(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]").text
    # end

  end
end