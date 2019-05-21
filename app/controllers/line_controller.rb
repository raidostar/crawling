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
  DEFAULT_SLEEP = 8.freeze

  def index
    @date = Date.today
    @agent = Capybara::Session.new(:poltergeist)
    @cookie = nil
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'] })
    end
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist
    Capybara.default_max_wait_time = 3

    #login

    @agent.visit("https://account.line.biz/login?redirectUri=https%3A%2F%2Fadmanager.line.biz&status=success")
    sleep DEFAULT_SLEEP / 2
    @agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/a').click

    element1 = @agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/form/div/div[1]/input')
    element1.send_keys(ENV["LINE_ACCOUNT"])

    element2 = @agent.find(:xpath, '/html/body/div/div/div[3]/div/div[3]/div[2]/form/div/div[2]/input')
    element2.send_keys(ENV["LINE_PASSWORD"])

    element3 = @agent.find(:xpath, "//button[@type='submit']")
    element3.click

    #getting advertisers_info
    output = []
    @agent.find(:xpath, "//*[@id='main']/div/ul/li[2]/a").click
    sleep DEFAULT_SLEEP / 4
    @agent.find('.ic-datarangpicker').click
    sleep DEFAULT_SLEEP / 4
    @agent.find(:xpath, "//input[@name='daterangepicker_start']").set(@date.strftime('%Y%m%d'))
    @agent.find(:xpath, "//input[@name='daterangepicker_end']").set(@date.strftime('%Y%m%d'))
    @agent.find('.applyBtn').click
    sleep DEFAULT_SLEEP / 4

    tr_num = @agent.find_all(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr").size
    j=0
    for i in 1..tr_num
      imp = @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[4]").text
      if imp != "0"
        output[j] = @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[2]/div/a")["href"]
        j+=1
      end
    end


    advertiser_links = output
    sleep DEFAULT_SLEEP

    check_ad_num = 0
    tr_num = 0
    @agent.visit advertiser_links[check_ad_num]
    @agent.find(:xpath, "//main[@id='main']/div/ul/li[3]/a").click
    while(true)
      advertiser_id = @agent.current_path.delete("/adaccount/ad")
      advertiser_name = @agent.find(:xpath, "//*[@id='main']/div/div[1]/div[1]/h3/strong").text
      tr_num = @agent.find_all(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr").size
      for i in 1..tr_num
        imp = @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[15]").text
        if imp != "0"
          report = DailyReport.new(
            date: @date,
            advertiser_id: advertiser_id,
            advertiser_name: advertiser_name,
            order_id: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[10]").text,
            order_name: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[9]//a").text,
            schedule_id: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[8]").text,
            schedule_name: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[7]").text,
            creative_id: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[6]").text,
            creative_name: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[5]").text,
            creative_image_url: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr[1]/td[12]/div/a")["href"],
            imp: imp.gsub(/\D/, ''),
            click: @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[16]").text.gsub(/\D/, ''),
            cv:    @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[19]").text.gsub(/\D/, ''),
            net:   @agent.find(:xpath, "//*[@id='main']/div/div[3]/table/tbody/tr["+i.to_s+"]/td[25]").text.gsub(/\D/,'')
            )
          report.save
        end#if
      end#for
      begin
        @agent.find(:xpath, "//*[@id='main']/div/div[2]/div[1]/div[2]/nav/ul/li[2]/a").click
        sleep DEFAULT_SLEEP / 4
      rescue
        check_ad_num+=1
        if check_ad_num==advertiser_links.size
          break
        else
          @agent.visit advertiser_links[check_ad_num]
          @agent.find(:xpath, "//main[@id='main']/div/ul/li[3]/a").click
        end#if~else
      end#begin~rescue
    end#while
  end#def index
end#class