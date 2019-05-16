class AkaneController < ApplicationController
  require 'capybara'
  require 'capybara/poltergeist'
  require 'selenium-webdriver'
  require 'rest-client'
  require 'csv'


  DEFAULT_HEADERS = {
    'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
    'Accept': "text/html,application/xhtml+xml,application/xml;q=0.9,imgwebp,*/*;q=0.7"
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
    agent.visit("https://chrome.google.com/webstore/detail/buster-captcha-solver-for/mpbjkejclgfgadiemmefgebjfooflfhl/related")
    element0 = agent.find(:class, 'dd-Va g-c-wb g-eg-ua-Uc-c-za g-c-Oc-td-jb-oa g-c')

    begin
      element0 = agent.find(:xpath, '/html/body/div[4]/div[2]/div/div/div[2]/div[2]/div')
    rescue
      element0 = agent.find(:xpath, '/html/body/div[4]/div[2]/div/div/div[1]/div[2]/div')
    end
    element0.click

    agent = Selenium::WebDriver.for :chrome

    # # reCaptcha breaking for human in the google web store
    # agent.get("https://chrome.google.com/webstore/detail/buster-captcha-solver-for/mpbjkejclgfgadiemmefgebjfooflfhl/related")
    # sleep DEFAULT_SLEEP
    # begin
    #   element0 = agent.find_element(:xpath, '/html/body/div[4]/div[2]/div/div/div[2]/div[2]/div')
    # rescue
    #   element0 = agent.find_element(:xpath, '/html/body/div[4]/div[2]/div/div/div[1]/div[2]/div')
    # end
    # element0.click

    # sleep 5.freeze

    agent.get("https://www.akane-ad.com/agent/login")

    element1 = agent.find_element(:name, 'login_id')
    element1.send_keys(ENV["AKANE_ACCOUNT1"])
    sleep 1.freeze
    element1.send_keys(ENV["AKANE_ACCOUNT2"])
    sleep 2.freeze
    element1.send_keys(ENV["AKANE_ACCOUNT3"])

    sleep DEFAULT_SLEEP

    element2 = agent.find_element(:name, 'password')
    element2.send_keys(ENV["AKANE_PASSWORD1"])
    sleep 1.freeze
    element2.send_keys(ENV["AKANE_PASSWORD2"])
    sleep 2.freeze
    element2.send_keys(ENV["AKANE_PASSWORD3"])

    # #agent.find_element(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/a').click
    # #agent.find_element(:tag_name, "iframe").click

    # sleep 20.freeze

    # element2 = agent.find_element(:name, 'commit')
    # element2.click

    # sleep DEFAULT_SLEEP

    # @doc = agent.page_source

    @session = nil
    @cookie = nil
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'] })
    end
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist
    Capybara.default_max_wait_time = 3

    agent = Capybara::Session.new(:poltergeist)
    agent.visit("https://www.akane-ad.com/agent/login")
    # iframe = agent.find(:id, "mainTopLogin").find("form table iframe").click
    # agent.switch_to_frame(iframe)
    # agent.source
    # #agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/a').click

    # element1 = agent.find(:id, "login_id")
    # element1.send_keys(ENV["AKANE_ACCOUNT"])

    # sleep DEFAULT_SLEEP

    # element2 = agent.find(:id, "password")
    # element2.send_keys(ENV["AKANE_PASSWORD"])

    # # <iframe src="https://www.google.com/recaptcha/api2/anchor?ar=1&amp;k=6LcYVV4UAAAAAB475UplzDhwiBkLq0NoCXdcz07d&amp;co=aHR0cHM6Ly93d3cuYWthbmUtYWQuY29tOjQ0Mw..&amp;hl=en&amp;v=v1555968629716&amp;size=normal&amp;cb=vrxr2pfh42xl" width="304" height="78" role="presentation" name="a-1j7njo7i8dme" frameborder="0" scrolling="no" sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation allow-modals allow-popups-to-escape-sandbox"></iframe>


    # "//div[@id='mainTopLogin']/form/table/tbody/tr[3]/td/div/div/div/iframe"


  end#def
end#class