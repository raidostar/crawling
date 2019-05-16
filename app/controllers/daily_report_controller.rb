class DailyReportController < ApplicationController
  require "open-uri"
  require "mechanize"
  require "nokogiri"
  require "date"

  def index
    # login before crawling
    agent = Mechanize.new
    page = agent.get("https://www.logly.co.jp/")

    login = page.form_with(:action => "/users/sign_in")
    login.field_with(:name => "user[email]").value = ENV["LOGLY_ACCOUNT"]
    login.field_with(:name => "user[password]").value = ENV["LOGLY_PASSWORD"]
    login_result = agent.submit login

   # click the advertiser after login

    host_page = login_result.link_with(:text =>"すべての広告主").click # Move to the page of the clientlist from the main page
    @doc = host_page.css("div#collapse1 ul li") # Get the list of the names of the client
    host_num = @doc.css("a").size() # The number of the clients in Logly site

    advertiser_name = @doc.css("a")[2].text # Get the name of the advertiser_name
    advertiser_id = @doc.css("a")[2]["href"].delete("/agency/advertisers/redirect_to_dashboard")
    host_menu = host_page.link_with(:text=>advertiser_name).click # Move to the page of the advertiser_name
    item_page = agent.get("https://www.logly.co.jp/ads") # Move to the page of 広告アイテム
    @test1 = item_page.css("tr").text.split(" ") # Get the information of the table of 広告アイテム
    @test3 = item_page.css("tr")

    test2_page = item_page.link_with(:text=>"次へ").click # Move to the next page if there is
    # @test2 = !test2_page.nil? # Check the existence of the next page
    @test2 = test2_page.css("tr").text.split(" ")
    @test3_size = @test3.size()

    date = Date.today
    time = Time.now
    platform_id = 20
    advertiser_id
    advertiser_name
    group_advertiser_id=20
    order_id = @test3.css("td a")[3]["href"].delete("/campaigns")
    order_name = @test3.css("td")[4].text
    group_order_id = 20
    schedule_id = @test3.css("td a")[2]["href"].delete("/adgroups")
    schedule_name = @test3.css("td")[3].text
    group_schedule_id = 20
    creative_id = @test1[17]
    creative_name = @test1[18]
    creative_image_url = @test3.css("img")[0]["scr"]
    click_url = @test3.css("img")[0].text
    imp = @test1[23]
    click = @test1[24]
    cv = @test1[25]
    gross=0
    net=0
    created_at=time
    updated_at=time
    lock_version=0

    @report = DailyReport.new(date: date, platform_id: platform_id, advertiser_id: advertiser_id, advertiser_name: advertiser_name, group_advertiser_id: group_advertiser_id, order_id: order_id, order_name: order_name, group_order_id: group_order_id, schedule_id: schedule_id, schedule_name: schedule_name,  creative_id: creative_id, creative_name: creative_name, creative_image_url: creative_image_url, click_url: click_url, imp: imp, click: click, cv: cv, gross: gross, net: net, created_at: created_at, updated_at: updated_at, lock_version: lock_version)
    @report.save
  end


end
